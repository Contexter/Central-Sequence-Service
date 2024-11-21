import Vapor
import OpenAPIServe

/// Provides OpenAPI spec data from a file.
public struct FileDataProvider: DataProvider {
    private let filePath: String

    public init(filePath: String) {
        self.filePath = filePath
    }

    public func getData() -> String {
        guard let data = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            return ""
        }
        return data
    }
}
