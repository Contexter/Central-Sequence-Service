import Vapor
import Fluent

public func iteration_7(app: Application) {
    app.post("sequence") { req -> EventLoopFuture<Sequence> in
        let input = try req.content.decode(Sequence.self)
        return Sequence.query(on: req.db)
            .filter(\.$elementId == input.elementId)
            .first()
            .flatMap { existing in
                if let existing = existing {
                    existing.sequenceNumber += 1
                    existing.comment = input.comment
                    return existing.save(on: req.db).map { existing }
                } else {
                    input.sequenceNumber = 1
                    return input.save(on: req.db).map { input }
                }
            }
    }

    print("POST /sequence endpoint is ready at http://localhost:8080/sequence")
}
