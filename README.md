# Task Manager Mobile App

A production-ready Flutter mobile application for task management with SQLite local database persistence, featuring Material Design 3 UI and comprehensive CRUD operations.

## 🚀 Features

- **Full CRUD Operations** - Create, read, update, and delete tasks
- **Smart Filtering** - Filter by priority, category, and completion status
- **Real-time Search** - Search tasks by title or description
- **Local Persistence** - SQLite database for offline data storage
- **Material Design 3** - Modern, intuitive user interface
- **State Management** - Efficient state handling with Provider pattern
- **Color-coded Priorities** - Visual indicators (High: Red, Medium: Orange, Low: Green)

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter SDK (>=3.0.0) |
| Language | Dart |
| Database | SQLite (sqflite ^2.3.0) |
| State Management | Provider ^6.1.1 |
| Date Formatting | intl ^0.18.1 |

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point with Provider setup
├── models/
│   └── task.dart                  # Task data model
├── providers/
│   └── task_provider.dart         # State management logic
├── screens/
│   ├── home_screen.dart           # Task list with search & filters
│   ├── add_edit_task_screen.dart  # Task creation/editing form
│   └── task_detail_screen.dart    # Detailed task view
├── services/
│   └── database_helper.dart       # SQLite operations (Singleton)
└── widgets/
    └── task_card.dart             # Reusable task card component
```

## ⚡ Quick Start

```bash
# Clone repository
git clone https://github.com/abouguri/Task-Manager-Mobile-App.git
cd Task-Manager-Mobile-App

# Install dependencies
flutter pub get

# Run app
flutter run
```

## 📦 Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🗃️ Database Schema

```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  priority TEXT NOT NULL,           -- 'Low', 'Medium', 'High'
  category TEXT NOT NULL,            -- 'Work', 'Personal', 'Shopping', 'Health', 'Other'
  dueDate TEXT,
  isCompleted INTEGER NOT NULL DEFAULT 0,
  createdAt TEXT NOT NULL
);
```

## 🎯 Key Capabilities

- **Task Attributes**: Title, description, priority, category, due date, completion status
- **Sorting Logic**: Incomplete tasks first → By due date → By priority
- **Form Validation**: Required fields with min/max length checks
- **Error Handling**: Comprehensive try-catch blocks with user feedback
- **Clean Architecture**: Separation of concerns (Model-View-Provider)

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**@abouguri**
- GitHub: [@abouguri](https://github.com/abouguri)

---

Built with Flutter 💙
