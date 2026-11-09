import type { Medication, Profile } from '@/data/snapshot';
import { displayDob, displayPhone } from '@/domain/forms';

export function escapeHtml(text: string): string {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

const withBreaks = (text: string) => escapeHtml(text).replace(/\n/g, '<br>');
const orDash = (text: string) => (text.trim() ? withBreaks(text) : '—');

/** The file name a shared PDF gets, safe for any profile name. */
export function pdfFileName(profileName: string): string {
  const safe = profileName
    .replace(/[/\\:*?"<>|\u0000-\u001f]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  return `${safe || 'My Meds'} Medications.pdf`;
}

const STYLE = `
  @page { size: 8.5in 11in; margin: 0.5in; }
  * { box-sizing: border-box; }
  body { font-family: -apple-system, Helvetica, Arial, sans-serif; font-size: 12pt; color: #000; margin: 0; }
  h1 { font-size: 20pt; margin: 0 0 8pt; }
  dl { margin: 0 0 16pt; display: grid; grid-template-columns: max-content 1fr; gap: 3pt 12pt; }
  dt { font-weight: 600; }
  dd { margin: 0; overflow-wrap: anywhere; }
  .row { display: flex; gap: 12pt; padding: 10pt 0; border-top: 0.75pt solid #999; }
  .thumb { width: 54pt; height: 54pt; object-fit: cover; border-radius: 6pt; flex: none; }
  .text { flex: 1; min-width: 0; overflow-wrap: anywhere; }
  .name { font-weight: 600; }
  .empty { padding: 16pt 0; border-top: 0.75pt solid #999; }
`;

/** `thumbnails` maps a medication id to a data URI. A medication without one has no image. */
export function medicationListHtml(
  profile: Profile,
  medications: Medication[],
  thumbnails: ReadonlyMap<number, string>,
  generatedOn: string,
): string {
  const rows = medications
    .map((medication) => {
      const thumbnail = thumbnails.get(medication.id);
      const image = thumbnail ? `<img class="thumb" src="${escapeHtml(thumbnail)}" alt="">` : '';
      const dosage = medication.dosage ? `<div>${withBreaks(medication.dosage)}</div>` : '';
      const notes = medication.notes ? `<div>${withBreaks(medication.notes)}</div>` : '';
      return `<div class="row">${image}<div class="text"><div class="name">${withBreaks(medication.name)}</div>${dosage}${notes}</div></div>`;
    })
    .join('');

  return `<!doctype html><html><head><meta charset="utf-8"><style>${STYLE}</style></head><body>
<h1>${withBreaks(profile.name)}</h1>
<dl>
<dt>Date of Birth</dt><dd>${withBreaks(displayDob(profile.dob))}</dd>
<dt>Primary Care Physician</dt><dd>${orDash(profile.pcp)}</dd>
<dt>Pharmacy Phone</dt><dd>${orDash(displayPhone(profile.pharmacy))}</dd>
<dt>Health Conditions</dt><dd>${orDash(profile.healthConditions)}</dd>
<dt>Generated</dt><dd>${escapeHtml(generatedOn)}</dd>
</dl>
${rows || '<div class="empty">No medications listed</div>'}
</body></html>`;
}
