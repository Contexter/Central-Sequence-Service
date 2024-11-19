import os

def validate_redoc_setup():
    """
    Validate the setup for serving OpenAPI and ReDoc in a Vapor project.
    This script checks:
    1. File and directory structure.
    2. The presence of key files: `openapi.yml` and `redoc.leaf`.
    3. Routes and configurations in `routes.swift` and `configure.swift`.
    """

    # Define paths
    project_root = os.getcwd()  # Assuming this script is run from the project root
    resources_dir = os.path.join(project_root, "Resources")
    openapi_dir = os.path.join(resources_dir, "OpenAPI")
    views_dir = os.path.join(resources_dir, "Views")
    public_dir = os.path.join(project_root, "Public")
    redoc_assets_dir = os.path.join(public_dir, "redoc")
    routes_file = os.path.join(project_root, "Sources/App/routes.swift")
    configure_file = os.path.join(project_root, "Sources/App/configure.swift")

    # Files to check
    openapi_file = os.path.join(openapi_dir, "openapi.yml")
    redoc_leaf_file = os.path.join(views_dir, "redoc.leaf")
    redoc_css_file = os.path.join(redoc_assets_dir, "redoc.standalone.css")
    redoc_js_file = os.path.join(redoc_assets_dir, "redoc.standalone.js")

    # Results
    results = []

    # Check directories
    if not os.path.isdir(openapi_dir):
        results.append(f"Missing directory: {openapi_dir}")
    if not os.path.isdir(views_dir):
        results.append(f"Missing directory: {views_dir}")
    if not os.path.isdir(redoc_assets_dir):
        results.append(f"Missing directory: {redoc_assets_dir}")

    # Check files
    if not os.path.isfile(openapi_file):
        results.append(f"Missing file: {openapi_file}")
    if not os.path.isfile(redoc_leaf_file):
        results.append(f"Missing file: {redoc_leaf_file}")
    if not os.path.isfile(redoc_css_file):
        results.append(f"Missing file: {redoc_css_file}")
    if not os.path.isfile(redoc_js_file):
        results.append(f"Missing file: {redoc_js_file}")

    # Check routes.swift
    if not os.path.isfile(routes_file):
        results.append(f"Missing file: {routes_file}")
    else:
        with open(routes_file, "r") as f:
            content = f.read()
            if "app.get(\"openapi.yml\")" not in content:
                results.append(f"Route for '/openapi.yml' not found in: {routes_file}")
            if "app.get(\"docs\")" not in content:
                results.append(f"Route for '/docs' not found in: {routes_file}")

    # Check configure.swift
    if not os.path.isfile(configure_file):
        results.append(f"Missing file: {configure_file}")
    else:
        with open(configure_file, "r") as f:
            content = f.read()
            if "app.views.use(.leaf)" not in content:
                results.append(f"Leaf configuration not found in: {configure_file}")

    # Output results
    if results:
        print("Validation Failed:")
        for result in results:
            print(f"- {result}")
    else:
        print("Validation Passed: All required files, directories, and configurations are present.")

# Run the validation
if __name__ == "__main__":
    validate_redoc_setup()

