# SavantCare Journal iOS App

A healthcare journal iOS application for patients to record daily health entries, moods, symptoms, and medications.

## 🎯 Features

- ✅ Create, read, update, and delete journal entries
- ✅ Track mood with emoji indicators (10 different moods)
- ✅ Record symptoms and medications
- ✅ Date and time-stamped entries
- ✅ REST API integration with MySQL backend
- ✅ Modern SwiftUI interface
- ✅ Pull-to-refresh functionality
- ✅ Async/await networking
- ✅ Beautiful gradient cards
- ✅ Error handling with alerts

## 📱 Screenshots

### Main Features
- **Journal List**: Beautiful card-based list of all entries
- **Create Entry**: Intuitive form with mood picker
- **Entry Detail**: Detailed view with edit/delete options
- **Empty State**: Welcoming screen for first-time users

## 🛠 Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- macOS 12.0+ (for development)

## 📂 Project Structure

```
savantcare-journal-ios-app/
├── Models/
│   ├── JournalEntry.swift
│   └── User.swift
├── Views/
│   ├── JournalListView.swift
│   ├── JournalEntryView.swift
│   └── EntryDetailView.swift
├── ViewModels/
│   └── JournalViewModel.swift
├── Services/
│   └── APIService.swift
├── Utilities/
│   └── Constants.swift
└── ContentView.swift
```

## 🚀 Setup Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd savantcare-journal-ios-app
```

### 2. Update API Configuration
Open `Utilities/Constants.swift` and update the base URL:

```swift
struct Constants {
    struct API {
        static let baseURL = "https://your-api-domain.com/api/v1"
    }
}
```

### 3. Configure Info.plist
Add this to your `Info.plist` to allow HTTP requests (for development):

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 4. Build and Run
1. Open the project in Xcode
2. Select your target device/simulator
3. Press `Cmd + R` to build and run

## 🌐 Backend API Requirements

### Required Endpoints

#### 1. Create Journal Entry
```
POST /journal

Request Body:
{
  "patient_id": "PATIENT_001",
  "title": "Feeling Better Today",
  "content": "Had a good day...",
  "mood": "😊 Happy",
  "symptoms": "Mild headache",
  "medications": "Aspirin 500mg"
}

Response:
{
  "success": true,
  "message": "Entry created successfully",
  "data": {
    "id": 1,
    "patient_id": "PATIENT_001",
    "title": "Feeling Better Today",
    "content": "Had a good day...",
    "mood": "😊 Happy",
    "symptoms": "Mild headache",
    "medications": "Aspirin 500mg",
    "created_at": "2026-01-07T10:00:00Z",
    "updated_at": "2026-01-07T10:00:00Z"
  }
}
```

#### 2. Get Patient Entries
```
GET /journal/patient/:patientId

Response:
{
  "success": true,
  "message": "Entries retrieved successfully",
  "data": [...]
}
```

#### 3. Update Journal Entry
```
PUT /journal/:id

Request Body: Same as Create
Response: Same as Create
```

#### 4. Delete Journal Entry
```
DELETE /journal/:id

Response:
{
  "success": true,
  "message": "Entry deleted successfully"
}
```

## 🗄 Database Schema (MySQL)

```sql
CREATE DATABASE savantcare_journal;

USE savantcare_journal;

CREATE TABLE journal_entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    mood VARCHAR(50) NOT NULL,
    symptoms TEXT,
    medications TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_patient_id (patient_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## 📖 Usage Guide

### Creating an Entry
1. Tap the "+" button in the top right
2. Fill in the title (required)
3. Select your mood
4. Write your journal entry (required)
5. Optionally add symptoms and medications
6. Tap "Save Entry"

### Viewing Entries
- Scroll through the list to see all entries
- Tap any entry to view full details
- Pull down to refresh the list

### Editing an Entry
1. Tap on an entry to view details
2. Tap the menu icon (•••) in the top right
3. Select "Edit"
4. Make your changes
5. Tap "Update Entry"

### Deleting an Entry
1. Tap on an entry to view details
2. Tap the menu icon (•••) in the top right
3. Select "Delete"
4. Confirm deletion

## 🎨 Available Moods

- 😊 Happy
- 😐 Neutral
- 😔 Sad
- 😰 Anxious
- 😣 Pain
- 😴 Tired
- 😌 Calm
- 😠 Frustrated
- 🤒 Sick
- 💪 Energetic

## 🏗 Architecture

### Design Pattern
- **MVVM (Model-View-ViewModel)**: Clean separation of concerns
- **Repository Pattern**: APIService handles all network calls
- **Dependency Injection**: ViewModels injected into views

### Technologies
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming with @Published properties
- **async/await**: Modern Swift concurrency
- **URLSession**: Native networking

## 🔐 Security Considerations

### For Production:
1. Implement user authentication
2. Use HTTPS only
3. Store tokens securely in Keychain
4. Implement proper error handling
5. Add input validation
6. Enable SSL pinning
7. Implement rate limiting

## 🐛 Troubleshooting

### App crashes on launch
- Check that all files are added to target
- Verify bundle identifier is correct

### Network errors
- Verify API URL in Constants.swift
- Check Info.plist for App Transport Security
- Ensure backend is running and accessible

### Data not loading
- Check backend API response format
- Verify JSON encoding/decoding keys match
- Check console for error messages

## 📝 TODO / Future Enhancements

- [ ] Add user authentication
- [ ] Implement data persistence (Core Data/Realm)
- [ ] Add search functionality
- [ ] Implement filtering by mood/date
- [ ] Add export to PDF feature
- [ ] Implement push notifications for reminders
- [ ] Add charts/analytics for mood tracking
- [ ] Implement offline mode
- [ ] Add photo attachments
- [ ] Multi-language support

## 📄 License

Proprietary - SavantCare Healthcare

## 👥 Contact

For questions or support, contact the development team at:
- Email: support@savantcare.com
- Website: https://savantcare.com

## 🤝 Contributing

This is a private healthcare project. Please contact the development team for contribution guidelines.

---

**Built with ❤️ for better healthcare**