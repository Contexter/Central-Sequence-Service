# Typesense Synchronization for Central Sequence Service

This document describes the synchronization process between the Central Sequence Service and the Typesense search engine. The integration ensures that sequence data is searchable in real-time.

## Overview
The synchronization process pushes sequence records from the SQLite database to a Typesense collection. This ensures consistent and real-time indexing of sequence-related data.

## Typesense Collection Configuration

### Collection Name
`sequences`

### Fields
| Field Name        | Data Type    | Indexing Options | Description                          |
|-------------------|--------------|------------------|--------------------------------------|
| `id`              | int32        | Primary Key      | Unique identifier for each sequence. |
| `element_type`    | string       | Facet, Search    | Type of the element (e.g., `script`).|
| `element_id`      | int32        | Search           | Identifier for the element.          |
| `sequence_number` | int32        | Sortable         | The sequence number assigned.        |
| `comment`         | string       | Full-Text Search | Contextual explanation.              |
| `created_at`      | string       | Sortable         | Timestamp of record creation.        |

## Synchronization Workflow

### 1. Record Creation
- Upon creating a new sequence in the `sequences` table, the service immediately queues the record for indexing in Typesense.
- Fields from the `sequences` table map directly to the Typesense collection.

### 2. Synchronization Process
1. **Queueing**: The service adds the record to a queue for indexing.
2. **API Request**: The record is sent to Typesense using the `/collections/{collection}/documents` API endpoint.
3. **Validation**: Typesense validates the data schema and indexes the record.

### 3. Retry Mechanism
- If the synchronization fails:
  - The service retries once immediately.
  - If the second attempt fails, the record is logged for manual intervention.

## Example API Request

### Adding a Document
```bash
curl -X POST 'http://<TYPESENSE_HOST>:8108/collections/sequences/documents' \
-H 'X-TYPESENSE-API-KEY: <YOUR_API_KEY>' \
-H 'Content-Type: application/json' \
-d '{
  "id": 123,
  "element_type": "script",
  "element_id": 123,
  "sequence_number": 1,
  "comment": "Initial sequence assignment",
  "created_at": "2024-12-14T12:00:00Z"
}'
```

### Deleting a Document
```bash
curl -X DELETE 'http://<TYPESENSE_HOST>:8108/collections/sequences/documents/123' \
-H 'X-TYPESENSE-API-KEY: <YOUR_API_KEY>'
```

## Error Handling

### Common Errors
| Error Code | Cause                                   | Resolution                          |
|------------|----------------------------------------|-------------------------------------|
| `400`      | Invalid document schema                | Ensure all fields match the schema. |
| `404`      | Document not found during deletion     | Verify the document ID.             |
| `500`      | Typesense server unavailable           | Retry after a short delay.          |

### Manual Intervention
- Failed records are logged in the `sync_errors` table for manual correction.

## Maintenance
- Periodic audits ensure that the SQLite database and Typesense collection remain consistent.
- Logs of synchronization attempts are reviewed weekly to identify recurring issues.

## Future Enhancements
- Implement batch synchronization for efficiency.
- Add monitoring for Typesense API response times to identify performance bottlenecks.

