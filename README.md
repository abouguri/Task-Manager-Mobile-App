# ✨ Task Manager

> A beautiful, minimalist Flutter task manager with swipe actions, statistics, and dark mode 🚀

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design%203-757575?style=flat&logo=material-design&logoColor=white)

## ✨ What makes it special?

🎨 **Modern Minimalist UI** - Clean design with purple gradient accents  
🌓 **Dark/Light Mode** - System-aware with manual toggle  
📱 **Expandable Cards** - No separate screens, everything inline  
👆 **Swipe Actions** - Swipe right to complete, left to delete  
📊 **Progress Statistics** - Track completion rate and daily goals  
⚙️ **Settings Screen** - Theme preferences and app info  
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
| **Swipe Actions** | Swipe right ✅ to complete, left 🗑️ to delete |
| **Statistics Card** | Beautiful gradient card with progress tracking 📈 |
| **Theme Toggle** | Dark mode for night owls 🦉 |
| **Settings Screen** | Customize your experience ⚙️ |
| **Priority Dots** | Glowing indicators with shadows ✨ |
| **Custom Checkboxes** | Smooth animations 🎯 |
| **Smart Badges** | Color-coded categories 🏷️ |
| **Empty State** | Helpful onboarding with feature highlights 🎉 |

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
│   ├── home_screen.dart      # Main screen with stats & expandable cards
│   ├── add_edit_task_screen.dart  # Create/edit tasks
│   └── settings_screen.dart  # Theme & app preferences
├── 💾 services/
│   └── database_helper.dart  # SQLite magic
└── 🎴 widgets/
    ├── task_card.dart        # Expandable card with swipe actions
    └── statistics_card.dart  # Progress tracking widget
```

## 🛠️ Tech Stack

**Built with**
- Flutter 3.x
- SQLite (sqflite)
- Provider (state management)
- Material Design 3

## 🎯 How to Use

1. **Add Task** - Tap the floating "Add Task" button
2. **View Statistics** - Check your progress at the top of the list
3. **Expand Card** - Click any task to see full details
4. **Swipe Right** - Complete a task with swipe gesture ✅
5. **Swipe Left** - Delete a task with confirmation 🗑️
6. **Toggle Complete** - Tap the checkbox
7. **Edit/Delete** - Expand card and use action buttons
8. **Switch Theme** - Tap sun/moon icon or go to Settings
9. **Settings** - Tap gear icon for preferences
10. **Search** - Use the search icon
11. **Filter** - Tap the filter icon

## 🌟 Cool Details

- 🎨 Gradient statistics card with progress bar
- 👆 Swipe gestures with visual feedback
- 📊 Real-time completion tracking
- ⚙️ Comprehensive settings screen
- 🎭 Smooth fade-in animations for task cards
- 🎪 Scale animation for empty state
- 📅 Smart due date formatting (Today, Tomorrow, Overdue)
- 💫 Priority dots with glow effects
- 🎯 Dismissible cards with colored backgrounds
- 📱 Responsive design
- 🔔 Snackbar notifications for actions

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