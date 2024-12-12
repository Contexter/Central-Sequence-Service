import Foundation

/// Constructs a full path by appending a sub-path to a root directory.
public func constructPath(for subPath: String, in root: String) -> String {
    return "\(root)/\(subPath)"
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
            return configData.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        } catch {
            print("Error reading config file. Using defaults.")
        }
    }
    return defaultDirectories
}