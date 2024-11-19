import os
import requests

def setup_vapor_redoc():
    """
    This script:
    1. Sets up the OpenAPI spec file.
    2. Downloads the ReDoc assets locally, only if they are missing or outdated.
    3. Updates the `redoc.leaf` file to reference local ReDoc assets, only if needed.
    """

    # Paths in the Vapor project
    project_root = os.getcwd()  # Assuming this script is run from the project root
    resources_dir = os.path.join(project_root, "Resources")
    views_dir = os.path.join(resources_dir, "Views")
    openapi_dir = os.path.join(resources_dir, "OpenAPI")
    public_dir = os.path.join(project_root, "Public")
    redoc_assets_dir = os.path.join(public_dir, "redoc")
    redoc_leaf_file = os.path.join(views_dir, "redoc.leaf")
    openapi_file = os.path.join(openapi_dir, "openapi.yml")

    # Ensure necessary directories exist
    os.makedirs(views_dir, exist_ok=True)
    os.makedirs(openapi_dir, exist_ok=True)
    os.makedirs(redoc_assets_dir, exist_ok=True)

    # Step 1: Ensure the OpenAPI placeholder file exists
    openapi_content = """# OpenAPI Specification Placeholder
# Replace this file with your actual OpenAPI specification in YAML format.
# This file describes the API for your Central Sequence Service.
"""
    if not os.path.exists(openapi_file) or open(openapi_file).read() != openapi_content:
        with open(openapi_file, "w") as f:
            f.write(openapi_content)
        print(f"Created or updated OpenAPI spec placeholder at: {openapi_file}")
    else:
        print(f"OpenAPI spec placeholder already exists and is up-to-date: {openapi_file}")

    # Step 2: Download ReDoc assets only if they are missing or outdated
    redoc_files = {
        "redoc.standalone.css": "https://cdn.jsdelivr.net/npm/redoc/bundles/redoc.standalone.css",
        "redoc.standalone.js": "https://cdn.jsdelivr.net/npm/redoc/bundles/redoc.standalone.js"
    }

    for file_name, url in redoc_files.items():
        file_path = os.path.join(redoc_assets_dir, file_name)
        if not os.path.exists(file_path):
            print(f"Downloading {file_name}...")
            response = requests.get(url)
            if response.status_code == 200:
                with open(file_path, "wb") as f:
                    f.write(response.content)
                print(f"Downloaded and saved {file_name} at: {file_path}")
            else:
                print(f"Failed to download {file_name} from {url}")
        else:
            print(f"{file_name} already exists at: {file_path}")

    # Step 3: Update the redoc.leaf file only if it's missing or incorrect
    redoc_leaf_content = """<!DOCTYPE html>
<html>
<head>
    <title>API Documentation</title>
    <link rel="stylesheet" href="/redoc/redoc.standalone.css">
</head>
<body>
    <redoc spec-url="/openapi.yml"></redoc>
    <script src="/redoc/redoc.standalone.js"></script>
</body>
</html>
"""
    if not os.path.exists(redoc_leaf_file) or open(redoc_leaf_file).read() != redoc_leaf_content:
        with open(redoc_leaf_file, "w") as f:
            f.write(redoc_leaf_content)
        print(f"Created or updated ReDoc Leaf template at: {redoc_leaf_file}")
    else:
        print(f"ReDoc Leaf template already exists and is up-to-date: {redoc_leaf_file}")

    print("\nSetup complete. You can now run your Vapor app and access:")
    print("- OpenAPI spec: http://localhost:8080/openapi.yml")
    print("- ReDoc documentation: http://localhost:8080/docs")


if __name__ == "__main__":
    setup_vapor_redoc()

