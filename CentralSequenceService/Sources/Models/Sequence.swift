import Fluent
import Vapor

final class Sequence: Model, Content, @unchecked Sendable {
    static let schema = "sequences"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "element_id")
    var elementId: String

    @Field(key: "sequence_number")
    var sequenceNumber: Int

    @Field(key: "comment")
    var comment: String?

    init() {}

    init(id: UUID? = nil, elementId: String, sequenceNumber: Int, comment: String?) {
        self.id = id
        self.elementId = elementId
        self.sequenceNumber = sequenceNumber
        self.comment = comment
    }
}
