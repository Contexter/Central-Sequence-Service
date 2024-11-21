import os

def append_to_file(file_path, content, marker=None):
    """
    Appends content to a file after a specific marker. If no marker is found, content is appended to the end.
    """
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


def create_file(file_path, content):
    """
    Creates a file if it doesn't exist and writes content to it.
    """
    if not os.path.exists(file_path):
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        with open(file_path, "w") as f:
            f.write(content)


def main():
    # Path definitions
    package_file = "Package.swift"
    configure_file = "Sources/App/configure.swift"
    routes_file = "Sources/App/routes.swift"
    resources_dir = "Sources/Resources"
    views_dir = "Resources/Views"
    redoc_file = os.path.join(views_dir, "redoc.leaf")
    openapi_file = os.path.join(resources_dir, "openapi.yml")

    # Step 1: Update Package.swift
    package_dependency = (
        ".package(url: \"https://github.com/Contexter/OpenAPIServe.git\", from: \"1.0.0\"),"
    )
    target_dependency = ".product(name: \"OpenAPIServe\", package: \"OpenAPIServe\")"
    append_to_file(package_file, package_dependency, marker="dependencies: [")
    append_to_file(package_file, target_dependency, marker="dependencies: [")

    # Step 2: Add OpenAPI Specification file
    openapi_content = """
openapi: 3.0.0
info:
  title: Central Sequence Service API
  version: 1.0.0
paths: {}
"""
    create_file(openapi_file, openapi_content)

    # Step 3: Update configure.swift
    middleware_content = """
    // Middleware configuration for OpenAPIServe
    let openapiFilePath = app.directory.resourcesDirectory + "openapi.yml"
    app.middleware.use(OpenAPIMiddleware(filePath: openapiFilePath))
"""
    append_to_file(configure_file, middleware_content, marker="public func configure")

    # Step 4: Add a ReDoc route to routes.swift
    route_content = """
app.get("docs") { req -> EventLoopFuture<View> in
    let context = ["specURL": "/openapi.yml"]
    return req.view.render("redoc", context)
}
"""
    append_to_file(routes_file, route_content)

    # Step 5: Add ReDoc template
    redoc_content = """
<!DOCTYPE html>
<html>
<head>
    <title>API Documentation</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:300,400,700|Material+Icons">
    <style>
        body {
            margin: 0;
            padding: 0;
        }
    </style>
</head>
<body>
    <redoc spec-url="{{ specURL }}"></redoc>
    <script src="https://cdn.jsdelivr.net/npm/redoc@next/bundles/redoc.standalone.js"></script>
</body>
</html>
"""
    create_file(redoc_file, redoc_content)

    print("OpenAPIServe integration complete. Please build and run your project.")

if __name__ == "__main__":
    main()

