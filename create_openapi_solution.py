import os

def create_openapi_solution():
    # Dynamically get the root directory of the project (script's location)
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Define paths relative to the script directory
    resources_dir = os.path.join(script_dir, "Resources/OpenAPI")
    views_dir = os.path.join(script_dir, "Resources/Views")
    routes_file = os.path.join(script_dir, "Sources/App/routes.swift")
    openapi_file = os.path.join(resources_dir, "openapi.yml")
    redoc_leaf_file = os.path.join(views_dir, "redoc.leaf")

    # Ensure directories exist
    os.makedirs(resources_dir, exist_ok=True)
    os.makedirs(views_dir, exist_ok=True)

    # Placeholder content for OpenAPI spec
    openapi_placeholder = """# OpenAPI Specification Placeholder
# Replace this file with your actual OpenAPI specification in YAML format.
# This file describes the API for your Central Sequence Service.
"""

    # Leaf template for ReDoc
    redoc_template = """<!DOCTYPE html>
<html>
<head>
    <title>API Documentation</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/redoc/bundles/redoc.standalone.css">
</head>
<body>
    <redoc spec-url="/openapi.yml"></redoc>
    <script src="https://cdn.jsdelivr.net/npm/redoc/bundles/redoc.standalone.js"></script>
</body>
</html>
"""

    # Route definitions for serving the spec and ReDoc page
    routes_content = """
import Vapor

func routes(_ app: Application) throws {
    // Serve the OpenAPI spec
    app.get("openapi.yml") { req -> Response in
        let filePath = app.directory.resourcesDirectory + "OpenAPI/openapi.yml"
        return req.fileio.streamFile(at: filePath)
    }

    // Serve the ReDoc documentation page
    app.get("docs") { req -> View in
        return req.view.render("redoc")
    }
}
"""

    # Write placeholder OpenAPI spec
    with open(openapi_file, "w") as file:
        file.write(openapi_placeholder)

    # Write ReDoc Leaf template
    with open(redoc_leaf_file, "w") as file:
        file.write(redoc_template)

    # Overwrite routes.swift with updated content
    with open(routes_file, "w") as file:
        file.write(routes_content)

    print(f"OpenAPI spec placeholder created at: {openapi_file}")
    print(f"ReDoc Leaf template created at: {redoc_leaf_file}")
    print(f"Routes updated at: {routes_file}")


# Execute the setup function
if __name__ == "__main__":
    create_openapi_solution()

