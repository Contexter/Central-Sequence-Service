import os

def write_file(path, content):
    """Writes content to a file, creating directories if needed."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(content)

def append_to_file(file_path, content, marker=None):
    """Appends content to a file after a specific marker. If no marker is found, appends to the end."""
    if not os.path.exists(file_path):
        with open(file_path, "w") as f:
            f.write(content)
        return

    with open(file_path, "r") as f:
        lines = f.readlines()

    if marker:
        for i, line in enumerate(lines):
            if marker in line:
                lines.insert(i + 1, content + "\n")
                break
        else:
            lines.append(content + "\n")
    else:
        lines.append(content + "\n")

    with open(file_path, "w") as f:
        f.writelines(lines)

def main():
    # Paths
    file_data_provider_path = "Sources/App/Providers/FileDataProvider.swift"
    configure_file = "Sources/App/configure.swift"

    # Step 1: Create FileDataProvider.swift
    file_data_provider_content = """
import Vapor

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
"""
    write_file(file_data_provider_path, file_data_provider_content)
    print(f"Created: {file_data_provider_path}")

    # Step 2: Update configure.swift
    configure_content = """
    // Middleware configuration for OpenAPIServe
    let openapiFilePath = app.directory.resourcesDirectory + "openapi.yml"
    let dataProvider = FileDataProvider(filePath: openapiFilePath)
    app.middleware.use(OpenAPIMiddleware(dataProvider: dataProvider))
"""
    append_to_file(configure_file, configure_content, marker="public func configure")

    print(f"Updated: {configure_file}")

    # Step 3: Confirm completion
    print("OpenAPIMiddleware setup complete. Rebuild your project to apply the changes.")

if __name__ == "__main__":
    main()

