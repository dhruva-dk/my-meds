//riverpod package
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication_tracker/database/objectbox.dart';
import 'package:medication_tracker/models/medication_model.dart';



// Provider for ObjectBox
final objectBoxProvider = FutureProvider<ObjectBox>((ref) async {
  return await ObjectBox.create();
});

// State Notifier for Medication
class MedicationNotifier extends StateNotifier<List<Medication>> {
  final Ref ref;

  MedicationNotifier(this.ref) : super([]);

  // Load all medications
  Future<void> loadMedications() async {
    final objectBox = await ref.read(objectBoxProvider.future);
    final medications = objectBox.getAllMedications();
    state = medications;
  }

  // Add a new medication
  Future<void> addMedication(Medication medication) async {
    final objectBox = await ref.read(objectBoxProvider.future);
    objectBox.createMedication(medication);
    // Update the state
    state = [...state, medication];
  }

  // Update an existing medication
  Future<void> updateMedication(Medication medication) async {
    final objectBox = await ref.read(objectBoxProvider.future);
    objectBox.updateMedication(medication);
    state = state.map((m) => m.id == medication.id ? medication : m).toList();
  }

  // Delete a medication
  Future<void> deleteMedication(int id) async {
    final objectBox = await ref.read(objectBoxProvider.future);
    objectBox.deleteMedication(id);
    state = state.where((m) => m.id != id).toList();
  }
}

// Provider for MedicationNotifier
final medicationListProvider =
    StateNotifierProvider<MedicationNotifier, List<Medication>>((ref) {
  return MedicationNotifier(ref);
});
