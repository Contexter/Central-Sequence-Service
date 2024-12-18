import Vapor
import OpenAPIVapor

func registerRoutes(app: Application) throws {
    let transport = VaporTransport(routesBuilder: app)
    let api = CentralSequenceServiceAPI(app: app)
    try api.registerHandlers(on: transport)
    app.logger.info("All OpenAPI routes registered successfully.")
}
