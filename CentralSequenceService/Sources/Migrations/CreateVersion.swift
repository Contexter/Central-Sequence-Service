import Fluent

struct CreateVersion: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("versions")
            .id()
            .field("element_id", .string, .required)
            .field("version_number", .int, .required)
            .field("comment", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("versions").delete()
    }
}
