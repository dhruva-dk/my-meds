class FDADrug {
  final String brandName;
  final String genericName;
  final String dosageForm;

  final String ndc;

  FDADrug({
    required this.brandName,
    required this.genericName,
    required this.dosageForm,
    required this.ndc,
  });

  factory FDADrug.fromMap(Map<String, dynamic> json) {
    return FDADrug(
      brandName: json['brand_name'] ?? 'Unknown Brand Name',
      genericName: json['generic_name'] ?? 'Unknown Generic Name',
      dosageForm: json['dosage_form'] ?? 'Unknown',
      ndc: json['product_ndc'] ?? 'Unknown',
    );
  }
}
