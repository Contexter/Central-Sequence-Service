import Foundation
import Utilities

func iteration1Setup() {
    let projectRoot = projectFileManager.currentDirectoryPath
    print("Starting iteration 1 setup in: \(projectRoot)")

    do {
        // Validate project root
        try validateProjectRoot(requiredFiles: ["CentralSequenceService/Package.swift"])

        // Fetch directories to create
        let directories = getProjectDirectories()

        // Ensure all directories are created
        for dir in directories {
            let path = constructPath(for: dir, in: projectRoot)
            try createDirectoryIfNeeded(at: path)
        }

        // Create template file if it doesn't exist
        let templatesDir = constructPath(for: "Templates", in: projectRoot)
        try createDirectoryIfNeeded(at: templatesDir)

        let templatePath = constructPath(for: "Templates/setup_template.swift", in: projectRoot)
        if !projectFileManager.fileExists(atPath: templatePath) {
            let defaultTemplateContent = """
            // Default Setup Template
            // This file serves as a starting point for building a simple Vapor application.
            // It demonstrates a basic setup, including an endpoint for testing.
            // You can modify or extend this template as needed for specific project iterations.

            import Vapor // Import Vapor framework for building server-side Swift applications.

            // MARK: - Application Initialization
            // Create an instance of the Vapor Application configured for development.
            var app = Application(.development)

            // Use defer to ensure the application shuts down gracefully when the script ends.
            defer { app.shutdown() }

            // MARK: - Route Definitions
            // Define a simple GET endpoint at "/setup".
            // When accessed, this endpoint returns a success message.
            app.get("setup") { req in
                // This closure handles incoming requests to the "/setup" route.
                // It returns a simple message confirming the setup execution.
                return "Setup executed successfully!"
            }

            // MARK: - Application Execution
            // Run the application.
            // The `try` keyword indicates that this operation may throw an error, 
            // which must be handled appropriately.
            try app.run()

            // MARK: - Notes
            // 1. This template serves as a baseline for testing setup-related tasks.
            // 2. The `/setup` route can be replaced or extended to implement specific features.
            // 3. For production use, replace `.development` with `.production` in the application initialization.
            // 4. If additional middleware or configurations are required, they should be added before `app.run()`.

            // Example:
            // app.middleware.use(MyCustomMiddleware())
            """
            try writeFile(at: templatePath, content: defaultTemplateContent, overwrite: true)
        }

        print("Iteration 1 setup completed successfully.")
    } catch {
        print("Error during iteration 1 setup: \(error.localizedDescription)")
    }
}

// Call the setup function
iteration1Setup()