# Database Schema for Central Sequence Service

This document outlines the database schema for the SQLite database used in the Central Sequence Service. The schema ensures efficient storage and retrieval of sequence-related data.

## Tables

### 1. `sequences`
This table stores the sequence information for various elements.

| Column Name       | Data Type    | Constraints                     | Description                          |
|-------------------|--------------|----------------------------------|--------------------------------------|
| `id`              | INTEGER      | PRIMARY KEY AUTOINCREMENT        | Unique identifier for each sequence. |
| `element_type`    | TEXT         | NOT NULL                        | The type of element (e.g., `script`, `section`). |
| `element_id`      | INTEGER      | NOT NULL                        | Identifier for the element.          |
| `sequence_number` | INTEGER      | NOT NULL                        | The sequence number assigned.        |
| `comment`         | TEXT         |                                 | Contextual explanation.              |
| `created_at`      | TIMESTAMP    | DEFAULT CURRENT_TIMESTAMP        | When the record was created.         |

### Indexes
- **`idx_element_type`**: Index on the `element_type` column for faster queries.
- **`idx_element_id`**: Composite index on `element_type` and `element_id` to ensure unique combinations and improve retrieval performance.

## Example Queries

### Inserting a New Sequence
```sql
INSERT INTO sequences (element_type, element_id, sequence_number, comment)
VALUES ('script', 123, 1, 'Initial sequence assignment');
```

### Fetching a Sequence by Element
```sql
SELECT * FROM sequences
WHERE element_type = 'script' AND element_id = 123;
```

### Updating a Sequence Number
```sql
UPDATE sequences
SET sequence_number = 2
WHERE element_type = 'script' AND element_id = 123;
```

### Deleting a Sequence
```sql
DELETE FROM sequences
WHERE element_type = 'script' AND element_id = 123;
```

