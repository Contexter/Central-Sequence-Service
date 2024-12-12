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
        print("Created directory at: \(path)")
    } else {
        print("Directory already exists: \(path)")
    }
}

/// Writes content to a file, overwriting if specified.
public func writeFile(at path: String, content: String, overwrite: Bool = false) throws {
    if projectFileManager.fileExists(atPath: path) && !overwrite {
        print("File exists at \(path). Skipping.")
        return
    }
    try content.write(toFile: path, atomically: true, encoding: .utf8)
    print("File written at: \(path)")
}