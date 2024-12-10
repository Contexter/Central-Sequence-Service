import SQLite

struct DatabaseManager {
    static let shared = DatabaseManager()
    private let db: Connection

    private init() {
        let path = FileManager.default.temporaryDirectory.appendingPathComponent("central_sequence.sqlite3").path
        db = try! Connection(path)
        createTables()
    }

    private func createTables() {
        let sequences = Table("sequences")
        let id = Expression<String>("id")
        let sequenceNumber = Expression<Int>("sequenceNumber")

        try! db.run(sequences.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(sequenceNumber)
        })
    }

    /// Increments the sequence number for a given element or initializes it if it doesn’t exist.
    func incrementSequence(for uniqueID: String) -> Int {
        let sequences = Table("sequences")
        let sequenceNumber = Expression<Int>("sequenceNumber")
        let rowID = Expression<String>("id")

        if let current = try? db.pluck(sequences.filter(rowID == uniqueID)) {
            let newSequence = current[sequenceNumber] + 1
            try! db.run(sequences.filter(rowID == uniqueID).update(sequenceNumber <- newSequence))
            return newSequence
        } else {
            try! db.run(sequences.insert(rowID <- uniqueID, sequenceNumber <- 1))
            return 1
        }
    }

    /// Reorder sequences in batch.
    func reorderSequences(_ updates: [(String, Int)]) {
        let sequences = Table("sequences")
        let sequenceNumber = Expression<Int>("sequenceNumber")
        let rowID = Expression<String>("id")

        for (idValue, newSeq) in updates {
            try! db.run(sequences.filter(rowID == idValue).update(sequenceNumber <- newSeq))
        }
    }

    /// Insert a new version or update existing one (if needed).
    func setSequence(for uniqueID: String, to sequence: Int) {
        let sequences = Table("sequences")
        let sequenceNumber = Expression<Int>("sequenceNumber")
        let rowID = Expression<String>("id")

        if let _ = try? db.pluck(sequences.filter(rowID == uniqueID)) {
            try! db.run(sequences.filter(rowID == uniqueID).update(sequenceNumber <- sequence))
        } else {
            try! db.run(sequences.insert(rowID <- uniqueID, sequenceNumber <- sequence))
        }
    }
}
