package com.example.tasklist.service;
import org.springframework.stereotype.Service;
import java.util.List;
import com.example.tasklist.Task.Task;
import com.example.tasklist.repository.TaskRepository;

@Service
public class TaskService {
    private final TaskRepository repo;
    public TaskService(TaskRepository repo) { this.repo = repo; }

    public List<Task> all() { return repo.findAll(); }
    public Task create(Task task) { return repo.save(task); }
    public Task markCompleted(Long id) {
        Task t = repo.findById(id).orElseThrow();
        t.setCompleted(true);
        return repo.save(t);
    }
    public List<Task> filterByCompleted(boolean completed) {
        return repo.findByCompleted(completed);
    }
}
