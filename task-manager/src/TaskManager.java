import java.util.ArrayList;
import java.util.List;

/**
 * TaskManager class manages a collection of tasks.
 * Provides methods to add, list, complete, and delete tasks.
 */
public class TaskManager {
    private ArrayList<Task> tasks;

    /**
     * Constructor initializes an empty task list.
     */
    public TaskManager() {
        this.tasks = new ArrayList<>();
    }

    /**
     * Adds a new task with the given description.
     *
     * @param description The description of the task to add
     */
    public void addTask(String description) {
        Task task = new Task(description);
        tasks.add(task);
        System.out.println("Task added successfully!");
    }

    /**
     * Lists all tasks with their index numbers.
     * Displays each task with its completion status.
     */
    public void listTasks() {
        if (tasks.isEmpty()) {
            System.out.println("No tasks to display.");
            return;
        }

        System.out.println("\n=== Your Tasks ===");
        for (int i = 0; i < tasks.size(); i++) {
            System.out.println((i + 1) + ". " + tasks.get(i));
        }
        System.out.println("==================\n");
    }

    /**
     * Marks a task as completed based on its index.
     *
     * @param index The index of the task to complete (1-based)
     * @throws IndexOutOfBoundsException if the index is invalid
     */
    public void completeTask(int index) {
        if (index < 1 || index > tasks.size()) {
            throw new IndexOutOfBoundsException("Invalid task number. Please enter a number between 1 and " + tasks.size());
        }

        Task task = tasks.get(index - 1);
        task.setCompleted(true);
        System.out.println("Task marked as complete: " + task.getDescription());
    }

    /**
     * Deletes a task based on its index.
     *
     * @param index The index of the task to delete (1-based)
     * @throws IndexOutOfBoundsException if the index is invalid
     */
    public void deleteTask(int index) {
        if (index < 1 || index > tasks.size()) {
            throw new IndexOutOfBoundsException("Invalid task number. Please enter a number between 1 and " + tasks.size());
        }

        Task task = tasks.remove(index - 1);
        System.out.println("Task deleted: " + task.getDescription());
    }

    /**
     * Returns the list of all tasks.
     * Used by FileStorage for saving tasks.
     *
     * @return List of all tasks
     */
    public List<Task> getTasks() {
        return tasks;
    }

    /**
     * Sets the task list.
     * Used by FileStorage when loading tasks.
     *
     * @param tasks The new list of tasks
     */
    public void setTasks(ArrayList<Task> tasks) {
        this.tasks = tasks;
    }
}
