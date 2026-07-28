import java.io.IOException;
import java.util.Scanner;

/**
 * Main class provides a command-line interface for the Task Manager.
 * Allows users to add, list, complete, delete, save, and load tasks.
 */
public class Main {
    private static TaskManager taskManager;
    private static FileStorage fileStorage;
    private static Scanner scanner;

    public static void main(String[] args) {
        taskManager = new TaskManager();
        fileStorage = new FileStorage();
        scanner = new Scanner(System.in);

        System.out.println("========================================");
        System.out.println("   Welcome to CLI Task Manager!");
        System.out.println("========================================\n");

        // Auto-load tasks on startup
        loadTasks();

        boolean running = true;
        while (running) {
            printMenu();
            running = handleUserInput();
        }

        scanner.close();
        System.out.println("\nThank you for using Task Manager. Goodbye!");
    }

    /**
     * Prints the main menu options.
     */
    private static void printMenu() {
        System.out.println("\n=== Task Manager Menu ===");
        System.out.println("1. Add task");
        System.out.println("2. List tasks");
        System.out.println("3. Complete task");
        System.out.println("4. Delete task");
        System.out.println("5. Save");
        System.out.println("6. Load");
        System.out.println("0. Exit");
        System.out.println("=========================");
        System.out.print("Enter your choice: ");
    }

    /**
     * Handles user input and executes the corresponding action.
     *
     * @return false if user wants to exit, true otherwise
     */
    private static boolean handleUserInput() {
        try {
            String input = scanner.nextLine().trim();
            
            // Handle empty input
            if (input.isEmpty()) {
                System.out.println("Please enter a valid option.");
                return true;
            }

            int choice;
            try {
                choice = Integer.parseInt(input);
            } catch (NumberFormatException e) {
                System.out.println("Invalid input. Please enter a number.");
                return true;
            }

            switch (choice) {
                case 1:
                    addTask();
                    break;
                case 2:
                    taskManager.listTasks();
                    break;
                case 3:
                    completeTask();
                    break;
                case 4:
                    deleteTask();
                    break;
                case 5:
                    saveTasks();
                    break;
                case 6:
                    loadTasks();
                    break;
                case 0:
                    return false;
                default:
                    System.out.println("Invalid choice. Please enter a number between 0 and 6.");
            }
        } catch (Exception e) {
            System.out.println("An error occurred: " + e.getMessage());
        }
        return true;
    }

    /**
     * Prompts user for task description and adds the task.
     */
    private static void addTask() {
        System.out.print("Enter task description: ");
        String description = scanner.nextLine().trim();
        
        if (description.isEmpty()) {
            System.out.println("Task description cannot be empty.");
            return;
        }
        
        taskManager.addTask(description);
    }

    /**
     * Prompts user for task number and marks it as complete.
     */
    private static void completeTask() {
        taskManager.listTasks();
        
        if (taskManager.getTasks().isEmpty()) {
            return;
        }
        
        System.out.print("Enter task number to complete: ");
        try {
            String input = scanner.nextLine().trim();
            int taskNumber = Integer.parseInt(input);
            taskManager.completeTask(taskNumber);
        } catch (NumberFormatException e) {
            System.out.println("Invalid input. Please enter a valid task number.");
        } catch (IndexOutOfBoundsException e) {
            System.out.println(e.getMessage());
        }
    }

    /**
     * Prompts user for task number and deletes it.
     */
    private static void deleteTask() {
        taskManager.listTasks();
        
        if (taskManager.getTasks().isEmpty()) {
            return;
        }
        
        System.out.print("Enter task number to delete: ");
        try {
            String input = scanner.nextLine().trim();
            int taskNumber = Integer.parseInt(input);
            taskManager.deleteTask(taskNumber);
        } catch (NumberFormatException e) {
            System.out.println("Invalid input. Please enter a valid task number.");
        } catch (IndexOutOfBoundsException e) {
            System.out.println(e.getMessage());
        }
    }

    /**
     * Saves tasks to file.
     */
    private static void saveTasks() {
        try {
            fileStorage.save(taskManager.getTasks());
        } catch (IOException e) {
            System.out.println("Error saving tasks: " + e.getMessage());
        }
    }

    /**
     * Loads tasks from file.
     */
    private static void loadTasks() {
        try {
            taskManager.setTasks(fileStorage.load());
        } catch (IOException e) {
            System.out.println("Error loading tasks: " + e.getMessage());
        }
    }
}
