CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,              -- Auto-incrementing unique ID
    title VARCHAR(255) NOT NULL,        -- Short title of the task
    description TEXT,                   -- Longer details about the task
    completed BOOLEAN DEFAULT FALSE,    -- Status flag
    created_at TIMESTAMP DEFAULT NOW(), -- When the task was created
    updated_at TIMESTAMP DEFAULT NOW()  -- Last update time
);
CREATE INDEX idx_tasks_completed ON tasks(completed);