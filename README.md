<table>
  <tr>
    <td width="75%"><img width="100%" alt="mymeds" src="https://github.com/user-attachments/assets/37596c13-368b-40e5-a8b3-78d35bb32a6d" /></td>
    <td width="25%"><img width="100%" alt="image" src="https://github.com/user-attachments/assets/f4417f15-8dee-4539-9792-e0f6b2cb690d" /></td>
  </tr>
</table>


# My Meds

A simple medication list app made to be easy to use and not send your data off-device.

## Architecture

The app follows a provider-based architecture using the `provider` package for state management. The main components are:

- **Providers**: Manage the state of the app. For example, the [`MedicationProvider`](lib/data/providers/medication_provider.dart) handles medication-related operations and exposes the active medication.
- **Models**: Define the data structures used in the app. For example, the [`Medication`](lib/data/model/medication_model.dart) model represents a medication.
- **Services**: Handle data operations and native package operations such as Image picking. For example, the [`DatabaseService`](lib/data/database/database.dart) interacts with the SQLite database.
- **UI**: The user interface components, including screens and widgets. For example, the [`CreateMedicationView`](lib/ui/create_medication/create_medication_view.dart) allows users to add new medications.

## Environment Setup
To set up the development environment for this project, follow these steps:

1. **Clone the repository**:
    ```sh
    git clone https://github.com/yourusername/medication_tracker.git
    cd medication_tracker
    ```

2. **Install Flutter**:
    Follow the instructions on the [official Flutter website](https://flutter.dev/docs/get-started/install) to install Flutter on your machine.

3. **Install dependencies**:
    ```sh
    flutter pub get
    ```

4. **Run the app**:
    ```sh
    flutter run
    ```

## Features

- Search functionality using FDA NDC REST APIs
- Full CRUD functionality using SQLite (flutter_sqflite) to add medications
- Profile input for personal notes
- Support for image upload using image_picker
- PDF export functionality using flutter_pdf

## Installation

Install on the app store: https://apps.apple.com/us/app/my-meds-personal-meds-list/id6475703887

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Contact


Dhruva Kumar  - dkumardevelopment@gmail.com

Thank you!
