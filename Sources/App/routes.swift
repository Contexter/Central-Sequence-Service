import Vapor

func routes(_ app: Application) throws {
    // Example route to ensure compilation
    app.get { req in
        return "It works!"
    }
    
    app.get("hello") { req -> String in
        return "Hello, world!"
    }
}
