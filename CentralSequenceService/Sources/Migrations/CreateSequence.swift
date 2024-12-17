import Fluent

struct CreateSequence: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("sequences")
            .id()
            .field("element_id", .string, .required)
            .field("sequence_number", .int, .required)
            .field("comment", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("sequences").delete()
    }
}
