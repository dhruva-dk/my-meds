import 'package:medication_tracker/models/medication_model.dart';
import 'package:objectbox/objectbox.dart';
//import objectbox genrator
import 'package:medication_tracker/objectbox.g.dart';


// ObjectBox setup and CRUD operations
class ObjectBox {
  late final Store store;
  late final Box<Medication> medicationBox;

  ObjectBox._create(this.store) {
    medicationBox = store.box<Medication>();
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }

  // CRUD Operations

  // Create
  int createMedication(Medication medication) {
    return medicationBox.put(medication);
  }

  // Read
  List<Medication> getAllMedications() {
    return medicationBox.getAll();
  }

  Medication? getMedication(int id) {
    return medicationBox.get(id);
  }

  // Update
  void updateMedication(Medication medication) {
    medicationBox.put(medication);
  }

  // Delete
  void deleteMedication(int id) {
    medicationBox.remove(id);
  }

  // Close the store
  void close() {
    store.close();
  }
}
