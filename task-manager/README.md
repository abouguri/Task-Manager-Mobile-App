# CLI Task Manager - Java Beginner Project

A command-line task management application built in Java to demonstrate fundamental Java programming concepts.

## 📚 Learning Goals

This project demonstrates:
- Java project structure
- Classes and objects
- Basic OOP principles (encapsulation, constructors)
- Collections (ArrayList)
- File I/O (BufferedReader, BufferedWriter)
- Exception handling (try/catch)
- Basic CLI interaction (Scanner)

## 🚀 Features

- ✅ Add tasks
- 📋 List all tasks
- ✔️ Mark tasks as completed
- 🗑️ Delete tasks
- 💾 Save tasks to file
- 📂 Load tasks from file
- ❌ Comprehensive error handling

## 📁 Project Structure

```
task-manager/
│
├── src/
│   ├── Main.java          # CLI interface and main loop
│   ├── Task.java          # Task data model
│   ├── TaskManager.java   # Task management logic
│   └── FileStorage.java   # File persistence
│
└── tasks.txt              # Saved tasks (auto-generated)
```

## 🏗️ Class Overview

### Task.java
- Represents a single task with description and completion status
- Provides getters/setters for encapsulation
- Includes a readable toString() method

### TaskManager.java
- Manages an ArrayList of Task objects
- Implements CRUD operations (Create, Read, Update, Delete)
- Validates task indices

### FileStorage.java
- Handles reading and writing tasks to/from file
- Uses simple text format: `status|description`
- Gracefully handles missing files

### Main.java
- Provides interactive CLI menu
- Handles user input with Scanner
- Implements main program loop

## 🔧 How to Compile and Run

From the `src` directory:

```bash
# Compile all Java files
javac *.java

# Run the application
java Main
```

## 📖 Usage Example

```
=== Task Manager Menu ===
1. Add task
2. List tasks
3. Complete task
4. Delete task
5. Save
6. Load
0. Exit
=========================
Enter your choice: 1
Enter task description: Study Java
Task added successfully!

Enter your choice: 2

=== Your Tasks ===
1. [ ] Study Java
==================
```

## 🎯 File Format

Tasks are saved in `tasks.txt` with the following format:
```
0|Buy milk              # 0 = incomplete
1|Study Java            # 1 = complete
```

## ✨ Key Java Concepts Demonstrated

1. **Object-Oriented Programming**
   - Encapsulation (private fields, public methods)
   - Constructors (default and parameterized)
   - Method overriding (toString())

2. **Collections Framework**
   - ArrayList for dynamic task storage
   - List interface for abstraction

3. **Exception Handling**
   - Try-catch blocks for I/O operations
   - IndexOutOfBoundsException for invalid indices
   - NumberFormatException for invalid input

4. **File I/O**
   - BufferedReader/BufferedWriter for efficient file access
   - FileReader/FileWriter for file operations
   - String parsing with split()

5. **Control Flow**
   - While loops for main program loop
   - Switch statements for menu handling
   - If-else for validation

## 🎓 What This Project Shows Employers

- ✅ You can structure a Java program with multiple classes
- ✅ You understand OOP basics and encapsulation
- ✅ You can work with collections (ArrayList)
- ✅ You can persist data to files
- ✅ You can build interactive CLI tools
- ✅ You can handle errors gracefully
- ✅ You write clean, well-documented code

## 🔮 Potential Extensions

If you want to expand this project:
- Add due dates for tasks
- Add priority levels (high, medium, low)
- Sort tasks by various criteria
- Search functionality
- Convert to Maven/Gradle project
- Add JUnit tests
- Add categories/tags

## 📝 License

MIT License - Feel free to use this project for learning!

---

**Time Investment:** 6-10 hours total

**Difficulty Level:** Beginner-friendly

**Perfect for:** First Java project on a CV/portfolio
