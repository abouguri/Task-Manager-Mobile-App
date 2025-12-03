# ✨ Task Manager

> A beautiful, minimalist Flutter task manager with dark mode and expandable cards 🌙

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design%203-757575?style=flat&logo=material-design&logoColor=white)

## ✨ What makes it special?

🎨 **Modern Minimalist UI** - Clean design with purple accents  
🌓 **Dark/Light Mode** - Toggle theme with one tap  
📱 **Expandable Cards** - No separate screens, everything inline  
⚡ **Lightning Fast** - SQLite local storage  
🎯 **Smart Filters** - Priority, category, and status filters  
🔍 **Live Search** - Find tasks instantly  

## 🚀 Quick Start

```bash
# Get it running
git clone https://github.com/abouguri/Task-Manager-Mobile-App.git
cd Task-Manager-Mobile-App
flutter pub get
flutter run
```

## 🎮 Features

| What | How Cool Is It? |
|------|----------------|
| **Expandable Cards** | Click to expand - all details inline 🎴 |
| **Theme Toggle** | Dark mode for night owls 🦉 |
| **Priority Dots** | Glowing indicators with shadows ✨ |
| **Custom Checkboxes** | Smooth animations 🎯 |
| **Smart Badges** | Color-coded categories 🏷️ |

## 🎨 Design System

### Colors
- **Primary**: `#6C63FF` (Modern Purple) 💜
- **High Priority**: `#FF6B6B` (Coral Red) 🔴
- **Medium Priority**: `#FFA94D` (Warm Orange) 🟠
- **Low Priority**: `#51CF66` (Fresh Green) 🟢

### Themes
- **Light Mode**: Clean white cards on soft grey background
- **Dark Mode**: Elegant dark cards (#1E1E1E) on rich black (#121212)

## 📦 Project Structure

```
lib/
├── 🎯 main.dart              # App entry + Theme provider
├── 📊 models/
│   └── task.dart             # Task data model
├── 🔄 providers/
│   └── task_provider.dart    # State management
├── 📱 screens/
│   ├── home_screen.dart      # Main screen with expandable cards
│   └── add_edit_task_screen.dart  # Create/edit tasks
├── 💾 services/
│   └── database_helper.dart  # SQLite magic
└── 🎴 widgets/
    └── task_card.dart        # Expandable card widget
```

## 🛠️ Tech Stack

**Built with**
- Flutter 3.x
- SQLite (sqflite)
- Provider (state management)
- Material Design 3

## 🎯 How to Use

1. **Add Task** - Tap the floating button
2. **Expand Card** - Click any task to see details
3. **Toggle Complete** - Tap the checkbox
4. **Edit/Delete** - Expand card and use action buttons
5. **Switch Theme** - Tap sun/moon icon in app bar
6. **Search** - Use the search icon
7. **Filter** - Tap the filter icon

## 🌟 Cool Details

- 🎨 Gradient status cards
- 📅 Smart due date formatting (Today, Tomorrow, Overdue)
- 🎭 Smooth expand/collapse animations
- 💫 Priority dots with glow effects
- 🎯 Minimalist badges
- 📱 Responsive design

## 🚢 Build It

```bash
# Android
flutter build apk --release

# iOS  
flutter build ios --release

# Web
flutter build web --release
```

## 💡 Architecture

**Clean & Simple**
- Models for data structure
- Providers for state
- Services for database
- Widgets for UI
- Screens for pages

## 🤝 Contributing

Found a bug? Have an idea? PRs welcome!

1. Fork it
2. Create your branch (`git checkout -b cool-feature`)
3. Commit your changes (`git commit -am 'Add cool feature'`)
4. Push (`git push origin cool-feature`)
5. Open a PR

## 📄 License

MIT License - go wild! 🎉

## 💬 Questions?

Open an issue and let's chat!

---

Made with 💜 and Flutter
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**@abouguri**
- GitHub: [@abouguri](https://github.com/abouguri)

---

Built with Flutter 💙
