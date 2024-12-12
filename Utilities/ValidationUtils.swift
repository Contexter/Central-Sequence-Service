import Foundation

public enum ValidationError: Error {
    case invalidProjectRoot
}

/// Validates that the script is running from the correct project root.
public func validateProjectRoot(requiredFiles: [String]) throws {
    for file in requiredFiles {
        let path = constructPath(for: file, in: projectFileManager.currentDirectoryPath)
        if !projectFileManager.fileExists(atPath: path) {
            print("Required file missing: \(path)")
            throw ValidationError.invalidProjectRoot
        }
    }
    print("Project root validated successfully.")
}