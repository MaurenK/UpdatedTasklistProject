package com.example.tasklist.controller;

import org.springframework.web.bind.annotation.*;
import java.util.List;
import com.example.tasklist.Task.Task;
import com.example.tasklist.service.TaskService;

@RestController
@RequestMapping("/api/tasks")
public class TaskController {
    private final TaskService service;
    public TaskController(TaskService s) { this.service = s; }

    @GetMapping
    public List<Task> list() { return service.all(); }

    @PostMapping
    public Task create(@RequestBody Task task) { return service.create(task); }

    @PostMapping("/{id}/complete")
    public Task complete(@PathVariable Long id) { return service.markCompleted(id); }

    @GetMapping("/filter")
    public List<Task> filter(@RequestParam boolean completed) {
        return service.filterByCompleted(completed);
    }
}
