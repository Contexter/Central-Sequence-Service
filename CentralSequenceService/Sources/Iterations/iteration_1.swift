import Foundation
import Vapor

func iteration1Setup(app: Application) {
    // Example 1: Using FileManager directly
    let fileManager = FileManager.default
    let tempDirectory = fileManager.temporaryDirectory
    print("Temporary directory path: \(tempDirectory.path)")

    // Example 2: Replace DirectoryUtils logic
    let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
    print("Home directory: \(homeDirectory)")

    // Example 3: Replace ValidationUtils logic
    let email = "example@test.com"
    let isValidEmail = email.contains("@") && email.contains(".")
    print("Is '\(email)' a valid email? \(isValidEmail)")

    // Define a route for this iteration
    app.get("/iteration1") { req -> String in
        return """
        Iteration 1 is running! 
        Home directory: \(homeDirectory) 
        Temp directory: \(tempDirectory.path) 
        Valid Email: \(isValidEmail)
        """
    }

    // Add additional logic here as needed
    print("Iteration 1 setup complete.")
}
