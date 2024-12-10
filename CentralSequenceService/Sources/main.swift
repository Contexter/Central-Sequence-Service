// Sources/main.swift
import Vapor

@main
struct Run {
    static func main() throws {
        let app = Application(.development)
        defer { app.shutdown() }

        app.get("hello") { req in
            "Hello, World!"
        }

        try app.run()
    }
}
