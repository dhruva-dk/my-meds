export interface FDADrug {
  brandName: string;
  genericName: string;
  dosageForm: string;
  ndc: string;
}

export class FDAAPIService {
  private static readonly baseUrl = "https://api.fda.gov/drug/ndc.json";

  static async searchMedications(query: string): Promise<FDADrug[]> {
    query = query.toLowerCase();
    const url = `${this.baseUrl}?search=brand_name:${query}+generic_name:${query}&limit=10`;

    try {
      const response = await fetch(url);
      if (response.ok) {
        const data = await response.json();
        if (data.results && data.results.length > 0) {
          return this.processMedications(data.results);
        }
      }
      throw new Error('No results found');
    } catch (e) {
      throw e;
    }
  }

  private static processMedications(medications: any[]): FDADrug[] {
    const toTitleCase = (str: string) => {
      if (!str) return '';
      return str.split(' ').map(word => {
        if (!word) return word;
        return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
      }).join(' ');
    };

    const uniqueMedications = new Map<string, FDADrug>();
    for (const med of medications) {
      const ndc = med.product_ndc || med.ndc; // the API might return product_ndc
      uniqueMedications.set(ndc, {
        brandName: toTitleCase(med.brand_name),
        genericName: toTitleCase(med.generic_name),
        dosageForm: toTitleCase(med.dosage_form),
        ndc: ndc,
      });
    }
    return Array.from(uniqueMedications.values());
  }
}
