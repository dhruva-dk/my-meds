import { File, Paths } from 'expo-file-system';
import { ImageManipulator, SaveFormat } from 'expo-image-manipulator';
import * as Print from 'expo-print';
import * as Sharing from 'expo-sharing';
import type { Medication } from '@/data/snapshot';
import { getSnapshot } from '@/data/store';
import { displayDate } from '@/domain/forms';
import { photoUri } from '@/ui/photoUri';
import { medicationListHtml, pdfFileName } from './medicationListHtml';

const THUMBNAIL_PIXELS = 216;
const LETTER = { width: 612, height: 792 };
const MARGIN = 36;

/** A small copy for the PDF, leaving the stored photo alone. A photo it can't read is skipped. */
async function thumbnailOf(medication: Medication): Promise<string | null> {
  const uri = photoUri(medication.photo);
  if (!uri) return null;
  try {
    const image = await ImageManipulator.manipulate(uri)
      .resize({ width: THUMBNAIL_PIXELS })
      .renderAsync();
    const { base64 } = await image.saveAsync({
      format: SaveFormat.JPEG,
      compress: 0.7,
      base64: true,
    });
    return base64 ? `data:image/jpeg;base64,${base64}` : null;
  } catch (error) {
    console.warn('Skipping a photo in the PDF', error);
    return null;
  }
}

/** Builds the active profile's PDF, opens the share sheet, and removes the temporary file. */
export async function exportMedicationList(): Promise<void> {
  const { activeProfile, medications } = getSnapshot();
  const thumbnails = new Map<number, string>();
  for (const medication of medications) {
    const thumbnail = await thumbnailOf(medication);
    if (thumbnail) thumbnails.set(medication.id, thumbnail);
  }
  const html = medicationListHtml(activeProfile, medications, thumbnails, displayDate(new Date()));
  const printed = await Print.printToFileAsync({
    html,
    ...LETTER,
    margins: { top: MARGIN, bottom: MARGIN, left: MARGIN, right: MARGIN },
  });
  const pdf = new File(Paths.cache, pdfFileName(activeProfile.name));
  try {
    new File(printed.uri).moveSync(pdf, { overwrite: true });
    await Sharing.shareAsync(pdf.uri, { mimeType: 'application/pdf', UTI: 'com.adobe.pdf' });
  } finally {
    if (pdf.exists) pdf.delete();
    const leftover = new File(printed.uri);
    if (leftover.exists) leftover.delete();
  }
}
