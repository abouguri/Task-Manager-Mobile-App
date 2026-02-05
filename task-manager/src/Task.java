/**
 * Task class represents a single task in the task manager.
 * Each task has a description and a completion status.
 */
public class Task {
    private String description;
    private boolean isCompleted;

    /**
     * Constructor to create a new task with a description.
     * Tasks are created as incomplete by default.
     *
     * @param description The description of the task
     */
    public Task(String description) {
        this.description = description;
        this.isCompleted = false;
    }

    /**
     * Constructor to create a task with a specific completion status.
     * Used when loading tasks from file.
     *
     * @param description The description of the task
     * @param isCompleted The completion status of the task
     */
    public Task(String description, boolean isCompleted) {
        this.description = description;
        this.isCompleted = isCompleted;
    }

    /**
     * Gets the description of the task.
     *
     * @return The task description
     */
    public String getDescription() {
        return description;
    }

    /**
     * Sets the description of the task.
     *
     * @param description The new task description
     */
    public void setDescription(String description) {
        this.description = description;
    }

    /**
     * Checks if the task is completed.
     *
     * @return true if the task is completed, false otherwise
     */
    public boolean isCompleted() {
        return isCompleted;
    }

    /**
     * Sets the completion status of the task.
     *
     * @param completed The new completion status
     */
    public void setCompleted(boolean completed) {
        this.isCompleted = completed;
    }

    /**
     * Returns a string representation of the task.
     * Format: [X] Description for completed tasks, [ ] Description for incomplete tasks.
     *
     * @return String representation of the task
     */
    @Override
    public String toString() {
        return "[" + (isCompleted ? "X" : " ") + "] " + description;
    }
}
