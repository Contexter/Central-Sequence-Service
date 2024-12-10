import Vapor
import OpenAPIVapor
import CentralSequenceService

@main
struct CentralSequenceServiceMain {
    static func main() throws {
        let app = Application()
        defer { app.shutdown() }

        // Register OpenAPI-defined API implementations
        try app.registerAPI(CentralSequenceService())

        // Optionally, serve OpenAPI spec at a route:
        // app.get("openapi.json") { req -> Response in
        //     let jsonData = try Data(contentsOf: URL(fileURLWithPath: "central-sequence-service.yaml"))
        //     return Response(body: Response.Body(data: jsonData))
        // }

        try app.run()
    }
}
