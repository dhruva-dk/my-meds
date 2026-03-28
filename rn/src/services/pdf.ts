import * as Print from 'expo-print';
import * as Sharing from 'expo-sharing';
import { Medication } from '../types';

export class PDFService {
  static async shareMedications(medications: Medication[]): Promise<void> {
    try {
      const html = this.generateHTML(medications);
      const { uri } = await Print.printToFileAsync({ html, base64: false });
      
      const isAvailable = await Sharing.isAvailableAsync();
      if (!isAvailable) {
        throw new Error('Sharing is not available on this device');
      }

      await Sharing.shareAsync(uri, { UTI: '.pdf', mimeType: 'application/pdf', dialogTitle: 'Medication List PDF' });
    } catch (e) {
      throw e;
    }
  }

  private static generateHTML(medications: Medication[]): string {
    const items = medications.map(med => {
      let imgTag = '';
      if (med.imageUrl) {
        // Because a local image URI may throw cors issues or not load in expo-print webview seamlessly without base64 or complete path prefix,
        // we append it. In this case, file:/// handles properly mostly, so we'll just drop it in.
        imgTag = `<img src="${med.imageUrl}" style="max-width: 300px; max-height: 300px; margin-top: 20px; border-radius: 12px;"/>`;
      }

      return `
        <div class="medication-card">
          <h2>Name: ${med.name || 'N/A'}</h2>
          <h3>Dosage: ${med.dosage || 'N/A'}</h3>
          <p>Additional Info: ${med.additionalInfo || 'N/A'}</p>
          ${imgTag}
        </div>
        <hr />
      `;
    }).join('');

    return `
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: 'Helvetica', 'Arial', sans-serif; padding: 20px; color: #333; }
            h1 { text-align: center; color: #1E3A8A; }
            .medication-card { margin-bottom: 20px; }
            h2 { font-size: 18px; margin: 5px 0; }
            h3 { font-size: 16px; margin: 5px 0; font-weight: normal; }
            p { font-size: 16px; margin: 5px 0; }
            hr { border: 0; border-top: 1px solid #ccc; margin: 20px 0; }
          </style>
        </head>
        <body>
          <h1>Medication List</h1>
          ${items}
        </body>
      </html>
    `;
  }
}
