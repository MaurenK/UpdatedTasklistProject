package com.example.tasklist.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import com.example.tasklist.Task.Task;

public interface TaskRepository extends JpaRepository<Task, Long> {
    List<Task> findByCompleted(boolean completed);
}