import java.io.*;
import java.util.ArrayList;
import java.util.List;

/**
 * FileStorage class handles persistence of tasks to and from a file.
 * Uses a simple text format: completion_status|description
 */
public class FileStorage {
    private static final String FILE_NAME = "tasks.txt";

    /**
     * Saves the list of tasks to a file.
     * Format: 0|description for incomplete tasks, 1|description for complete tasks
     *
     * @param tasks The list of tasks to save
     * @throws IOException if there's an error writing to the file
     */
    public void save(List<Task> tasks) throws IOException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_NAME))) {
            for (Task task : tasks) {
                String line = (task.isCompleted() ? "1" : "0") + "|" + task.getDescription();
                writer.write(line);
                writer.newLine();
            }
            System.out.println("Tasks saved successfully to " + FILE_NAME);
        }
    }

    /**
     * Loads tasks from a file.
     * Parses each line and creates Task objects.
     *
     * @return ArrayList of tasks loaded from the file
     * @throws IOException if there's an error reading from the file
     */
    public ArrayList<Task> load() throws IOException {
        ArrayList<Task> tasks = new ArrayList<>();
        File file = new File(FILE_NAME);

        // If file doesn't exist, return empty list
        if (!file.exists()) {
            System.out.println("No saved tasks found. Starting fresh!");
            return tasks;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(FILE_NAME))) {
            String line;
            while ((line = reader.readLine()) != null) {
                // Parse the line: status|description
                String[] parts = line.split("\\|", 2);
                if (parts.length == 2) {
                    boolean isCompleted = parts[0].equals("1");
                    String description = parts[1];
                    tasks.add(new Task(description, isCompleted));
                }
            }
            System.out.println("Tasks loaded successfully from " + FILE_NAME);
        }

        return tasks;
    }
}
