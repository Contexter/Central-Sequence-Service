import Vapor

func routes(_ app: Application) throws {
    // Example route
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    // ReDoc route
    app.get("docs") { req -> EventLoopFuture<View> in
        let context = ["specURL": "/openapi.yml"]
        return req.view.render("redoc", context)
    }
}
