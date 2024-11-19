import Vapor

func routes(_ app: Application) throws {
    // Serve the OpenAPI spec
        return req.fileio.streamFile(at: filePath)
    }

    // Serve the ReDoc documentation page
        return try await req.view.render("redoc")
    }
}
