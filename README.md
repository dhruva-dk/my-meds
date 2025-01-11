
<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/fc699ae1-50c4-4903-a2a6-20ccbc0f5959" alt="Image 5"></td>
    <td><img src="https://github.com/user-attachments/assets/fe35acba-78f0-4589-b103-f6087ccb34d2" alt="Image 4"></td>
    <td><img src="https://github.com/user-attachments/assets/70a094aa-bb49-43d8-89dc-ec892ebc3162" alt="Image 3"></td>
    <td><img src="https://github.com/user-attachments/assets/f3c5d2c8-1254-4925-96d0-5d4edd84aef2" alt="Image 2"></td>
    <td><img src="https://github.com/user-attachments/assets/008b4fb9-f56d-456a-9222-a782dbc56cc7" alt="Image 1"></td>
  </tr>
</table>

<h1>My Meds!</h1>

<p>A simple medication list app made to be easy to use and not send your data off-device.</p>

<h2>Architecture</h2>

<p>The app follows a provider-based architecture using the <code>provider</code> package for state management. The main components are:</p>

<ul>
  <li><strong>Providers</strong>: Manage the state of the app. For example, the <a href="lib/data/providers/medication_provider.dart"><code>MedicationProvider</code></a> handles medication-related operations and exposes the active medication.</li>
  <li><strong>Models</strong>: Define the data structures used in the app. For example, the <a href="lib/data/model/medication_model.dart"><code>Medication</code></a> model represents a medication.</li>
  <li><strong>Services</strong>: Handle data operations and native package operations such as Image picking. For example, the <a href="lib/data/database/database.dart"><code>DatabaseService</code></a> interacts with the SQLite database.</li>
  <li><strong>UI</strong>: The user interface components, including screens and widgets. For example, the <a href="lib/ui/create_medication/create_medication_view.dart"><code>CreateMedicationView</code></a> allows users to add new medications.</li>
</ul>

<h2>Environment Setup</h2>
<p>To set up the development environment for this project, follow these steps:</p>

<ol>
  <li><strong>Clone the repository</strong>:
    <pre><code>git clone https://github.com/yourusername/medication_tracker.git
cd medication_tracker</code></pre>
  </li>
  <li><strong>Install Flutter</strong>:
    Follow the instructions on the <a href="https://flutter.dev/docs/get-started/install">official Flutter website</a> to install Flutter on your machine.
  </li>
  <li><strong>Install dependencies</strong>:
    <pre><code>flutter pub get</code></pre>
  </li>
  <li><strong>Run the app</strong>:
    <pre><code>flutter run</code></pre>
  </li>
</ol>

<h2>Features</h2>

<ul>
  <li>Search functionality using FDA NDC REST APIs</li>
  <li>Full CRUD functionality using SQLite (flutter_sqflite) to add medications</li>
  <li>Profile input for personal notes</li>
  <li>Support for image upload using image_picker</li>
  <li>PDF export functionality using flutter_pdf</li>
</ul>

<h2>Installation</h2>

<p>Install on the app store: <a href="https://apps.apple.com/us/app/my-meds-personal-meds-list/id6475703887">https://apps.apple.com/us/app/my-meds-personal-meds-list/id6475703887</a></p>

<h2>License</h2>

<p>Distributed under the MIT License. See <code>LICENSE</code> for more information.</p>

<h2>Contact</h2>

<p>Dhruva Kumar - <a href="mailto:dkumardevelopment@gmail.com">dkumardevelopment@gmail.com</a></p>

<p>Thank you!</p>
