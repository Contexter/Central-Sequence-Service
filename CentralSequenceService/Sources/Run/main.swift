import Vapor
import App

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }

do {
    try configure(app) // Removed unnecessary 'await'
    try app.run()
} catch {
    app.logger.report(error: error)
    exit(1)
}
