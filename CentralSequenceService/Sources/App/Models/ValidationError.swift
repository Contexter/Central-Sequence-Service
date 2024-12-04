import Vapor

struct ValidationError: Swift.Error, Content {
    let reason: String
    let suggestion: String
    let context: String
}
