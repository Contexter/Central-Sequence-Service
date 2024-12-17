import Fluent
import Vapor

final class Version: Model, Content {
    static let schema = "versions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "element_id")
    var elementId: String

    @Field(key: "version_number")
    var versionNumber: Int

    @Field(key: "comment")
    var comment: String?

    init() {}

    init(id: UUID? = nil, elementId: String, versionNumber: Int, comment: String?) {
        self.id = id
        self.elementId = elementId
        self.versionNumber = versionNumber
        self.comment = comment
    }
}
