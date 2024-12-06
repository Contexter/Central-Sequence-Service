# Central Sequence Service

The **Central Sequence Service** is a backend API designed for managing sequence numbers and maintaining logical order for various elements within a story (e.g., scripts, characters, actions). It persists data to an SQLite database and integrates with **Typesense** for real-time search and retrieval capabilities. This implementation ensures robust synchronization between SQLite and Typesense while providing retry mechanisms for fault tolerance.

---

## **Features**

- **Sequence Management**: Generate, reorder, and manage sequence numbers.
- **Version Control**: Create new versions of elements with contextual comments.
- **SQLite Persistence**: Stores sequence data in a lightweight SQLite database.
- **Typesense Integration**: Synchronizes sequence data with a Typesense instance for advanced search capabilities.
- **Retry Mechanisms**: Ensures reliable synchronization with Typesense.
- **API Security**: Secured with API key authentication.

---

## **Requirements**

- **Swift** 5.8 or higher
- **Typesense** server running locally or accessible remotely
- **Docker** (optional for Typesense setup)
- **SQLite** pre-installed on the server

---

## **Setup and Installation**

### 1. Clone the Repository
```bash
git clone https://github.com/your-org/central-sequence-service.git
cd central-sequence-service
```

### 2. Install Dependencies
Ensure Swift and the required packages are installed:
```bash
swift package update
```

### 3. Start Typesense Server
Use Docker to run a local Typesense server:
```bash
docker run -d -p 8108:8108 -v/tmp/typesense-data:/data typesense/typesense:0.24.0 --data-dir /data --api-key=YOUR_API_KEY
```

### 4. Configure the Application
Update the Typesense API key and node details in `TypesenseManager.swift`:
```swift
let configuration = Configuration(
    nodes: [
        Node(
            host: "localhost",
            port: "8108",
            protocol: "http"
        )
    ],
    apiKey: "YOUR_API_KEY"
)
```

---

## **Run the Service**

1. Build and run the service:
   ```bash
   swift run
   ```

2. The service will be accessible at:
   - **Production**: `https://centralsequence.fountain.coach`
   - **Staging**: `https://staging.centralsequence.fountain.coach`
   - **Local**: `http://localhost:8080`

---

## **API Endpoints**

### **1. Generate Sequence Number**
- **POST** `/sequence`
- **Description**: Generates a new sequence number for an element.
- **Request Body**:
  ```json
  {
    "elementType": "script",
    "elementId": 1,
    "comment": "Creating a sequence."
  }
  ```
- **Response**:
  ```json
  {
    "sequenceNumber": 1,
    "comment": "Sequence number generated successfully."
  }
  ```

### **2. Reorder Elements**
- **PUT** `/sequence/reorder`
- **Description**: Updates sequence numbers for multiple elements.
- **Request Body**:
  ```json
  {
    "elementType": "script",
    "elements": [
      { "elementId": 1, "newSequence": 2 },
      { "elementId": 2, "newSequence": 1 }
    ],
    "comment": "Reordering elements."
  }
  ```
- **Response**:
  ```json
  {
    "updatedElements": [
      { "elementId": 1, "newSequence": 2 },
      { "elementId": 2, "newSequence": 1 }
    ],
    "comment": "Reordering completed successfully."
  }
  ```

### **3. Create New Version**
- **POST** `/sequence/version`
- **Description**: Creates a new version of an element.
- **Request Body**:
  ```json
  {
    "elementType": "script",
    "elementId": 1,
    "newVersionData": {},
    "comment": "Creating a new version."
  }
  ```
- **Response**:
  ```json
  {
    "versionNumber": 2,
    "comment": "Version created successfully."
  }
  ```

---

## **Implementation Details**

### SQLite Persistence
- Sequence numbers are stored in an SQLite database.
- Uses the **SQLite.swift** package for database operations.
- Schema includes:
  - `elementType`: The type of element (e.g., script, character).
  - `elementId`: Unique identifier for the element.
  - `sequenceNumber`: Current sequence number.

### Typesense Integration
- **Collection**: `sequences`
- **Schema**:
  - `elementType`: String
  - `elementId`: Integer
  - `sequenceNumber`: Integer
- **Synchronization**:
  - Data is indexed into Typesense during sequence creation, reordering, and versioning.
  - A retry mechanism ensures synchronization reliability.

### Retry Mechanism
- Implements exponential backoff for Typesense synchronization failures.
- Retries up to 3 times before logging an error.

---

## **Testing**

### Generate Sequence
```bash
curl -X POST http://localhost:8080/sequence \
     -H "Content-Type: application/json" \
     -d '{"elementType": "script", "elementId": 1, "comment": "Creating a sequence."}'
```

### Query Typesense Data
Retrieve all indexed documents:
```bash
curl -X GET "http://localhost:8108/collections/sequences/documents" \
     -H "X-TYPESENSE-API-KEY: YOUR_API_KEY"
```

---

## **Contributing**

1. Fork the repository.
2. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add your feature"
   ```
4. Push to your branch:
   ```bash
   git push origin feature/your-feature
   ```
5. Create a pull request.

---

## **License**

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## **Acknowledgements**

- [Typesense](https://typesense.org/) for real-time search capabilities.
- [SQLite.swift](https://github.com/stephencelis/SQLite.swift) for database integration.
- [Vapor](https://vapor.codes/) for the web framework.
