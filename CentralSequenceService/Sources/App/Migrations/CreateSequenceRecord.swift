import Fluent

struct CreateSequenceRecord: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("sequence_records")
            .id()
            .field("element_type", .string, .required)
            .field("element_id", .int, .required)
            .field("sequence_number", .int, .required)
            .field("comment", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("sequence_records").delete()
    }
}

