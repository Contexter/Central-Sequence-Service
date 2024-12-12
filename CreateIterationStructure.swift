import Foundation

// MARK: - Directory and File Definitions

let directories = [
    "Utilities",
    "Iterations",
    "Templates"
]

let files: [String: String] = [
    "Utilities/FileManagerUtils.swift": """
    import Foundation

    public enum FileError: Error {
        case permissionDenied
        case invalidPath
    }

    public let projectFileManager = FileManager.default

    /// Creates a directory at the specified path if it doesn't exist.
    public func createDirectoryIfNeeded(at path: String) throws {
        if !projectFileManager.fileExists(atPath: path) {
            try projectFileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            print("Created directory at: \\(path)")
        } else {
            print("Directory already exists: \\(path)")
        }
    }

    /// Writes content to a file, overwriting if specified.
    public func writeFile(at path: String, content: String, overwrite: Bool = false) throws {
        if projectFileManager.fileExists(atPath: path) && !overwrite {
            print("File exists at \\(path). Skipping.")
            return
        }
        try content.write(toFile: path, atomically: true, encoding: .utf8)
        print("File written at: \\(path)")
    }
    """,
    "Utilities/DirectoryUtils.swift": """
    import Foundation

    /// Constructs a full path by appending a sub-path to a root directory.
    public func constructPath(for subPath: String, in root: String) -> String {
        return "\\(root)/\\(subPath)"
    }

    /// Returns a list of directories to create, based on a config file or defaults.
    public func getProjectDirectories() -> [String] {
        let defaultDirectories = [
            "CentralSequenceService/Sources/App/Handlers",
            "CentralSequenceService/Sources/App/Middleware",
            "CentralSequenceService/Sources/App/Models",
            "CentralSequenceService/Sources/App/Config",
            "CentralSequenceService/Sources/Run"
        ]

        if let configFilePath = ProcessInfo.processInfo.environment["DIRECTORY_CONFIG_FILE"] {
            do {
                let configData = try String(contentsOfFile: configFilePath, encoding: .utf8)
                return configData.split(separator: "\\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            } catch {
                print("Error reading config file. Using defaults.")
            }
        }
        return defaultDirectories
    }
    """,
    "Utilities/ValidationUtils.swift": """
    import Foundation

    public enum ValidationError: Error {
        case invalidProjectRoot
    }

    /// Validates that the script is running from the correct project root.
    public func validateProjectRoot(requiredFiles: [String]) throws {
        for file in requiredFiles {
            let path = constructPath(for: file, in: projectFileManager.currentDirectoryPath)
            if !projectFileManager.fileExists(atPath: path) {
                print("Required file missing: \\(path)")
                throw ValidationError.invalidProjectRoot
            }
        }
        print("Project root validated successfully.")
    }
    """,
    "Iterations/iteration_1.swift": """
    import Foundation
    import Utilities

    func iteration1Setup() {
        let projectRoot = projectFileManager.currentDirectoryPath
        print("Starting iteration 1 setup in: \\(projectRoot)")

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
                let defaultTemplateContent = \"\"\"
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
                \"\"\"
                try writeFile(at: templatePath, content: defaultTemplateContent, overwrite: true)
            }

            print("Iteration 1 setup completed successfully.")
        } catch {
            print("Error during iteration 1 setup: \\(error.localizedDescription)")
        }
    }

    // Call the setup function
    iteration1Setup()
    """,
    "Templates/setup_template.swift": """
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
]

// MARK: - Directory and File Creation

/// Creates directories and files as defined in the `directories` and `files` structures.
func createStructure() {
    let fileManager = FileManager.default

    // Create directories
    for directory in directories {
        do {
            try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
            print("Created directory: \(directory)")
        } catch {
            print("Failed to create directory \(directory): \(error.localizedDescription)")
        }
    }

    // Create files
    for (filePath, content) in files {
        do {
            let directory = (filePath as NSString).deletingLastPathComponent
            if !fileManager.fileExists(atPath: directory) {
                try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
            }
            try content.write(toFile: filePath, atomically: true, encoding: .utf8)
            print("Created file: \(filePath)")
        } catch {
            print("Failed to create file \(filePath): \(error.localizedDescription)")
        }
    }
}

// Execute the creation
createStructure()

