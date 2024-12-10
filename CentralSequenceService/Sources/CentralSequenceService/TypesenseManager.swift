import Typesense

class TypesenseManager {
    static let shared = TypesenseManager()

    private let client: Client

    private init() {
        let configuration = Configuration(
            nodes: [ Node(host: "localhost", port: "8108", protocol: "http") ],
            apiKey: "YOUR_API_KEY" // Replace with your Typesense API key.
        )
        self.client = Client(configuration: configuration)
        setupCollection()
    }

    private func setupCollection() {
        let schema = CollectionSchema(
            name: "sequences",
            fields: [
                Field(name: "elementType", type: .string),
                Field(name: "elementId", type: .int32),
                Field(name: "sequenceNumber", type: .int32)
            ],
            defaultSortingField: "sequenceNumber"
        )

        // Create or ensure existing collection.
        do {
            let collections = try client.collections.retrieve()
            if !collections.contains(where: { $0.name == "sequences" }) {
                _ = try client.collections.create(schema: schema)
            }
        } catch {
            print("Collection setup failed: \(error)")
        }
    }

    func indexSequence(elementType: String, elementId: Int, sequenceNumber: Int) throws {
        let document: [String: Any] = [
            "elementType": elementType,
            "elementId": elementId,
            "sequenceNumber": sequenceNumber
        ]
        try client.documents(collectionName: "sequences").upsert(document: document)
    }
}
