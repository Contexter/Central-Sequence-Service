// File: Sources/main.swift
// Position: CentralSequenceService/Sources/main.swift
// Purpose: Entry point for the Vapor application, starting the server.

import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }

try configure(app)
try app.run()
