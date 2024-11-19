import os
import shutil

def rollback_redoc_setup():
    """
    Rollback the changes made during the ReDoc and OpenAPI setup.
    Removes the following:
    1. The 'Resources/OpenAPI' directory and its contents.
    2. The 'Resources/Views/redoc.leaf' file.
    3. The 'Public/redoc' directory and its contents.
    4. Verifies the 'routes.swift' and 'configure.swift' files, ensuring no leftover changes.
    """

    # Define paths
    project_root = os.getcwd()
    resources_dir = os.path.join(project_root, "Resources")
    openapi_dir = os.path.join(resources_dir, "OpenAPI")
    views_dir = os.path.join(resources_dir, "Views")
    redoc_leaf_file = os.path.join(views_dir, "redoc.leaf")
    public_dir = os.path.join(project_root, "Public")
    redoc_assets_dir = os.path.join(public_dir, "redoc")
    routes_file = os.path.join(project_root, "Sources/App/routes.swift")
    configure_file = os.path.join(project_root, "Sources/App/configure.swift")

    # List of rollback actions
    rollback_actions = []

    # Remove the OpenAPI directory and its contents
    if os.path.exists(openapi_dir):
        shutil.rmtree(openapi_dir)
        rollback_actions.append(f"Removed directory: {openapi_dir}")
    else:
        rollback_actions.append(f"Directory not found (already removed): {openapi_dir}")

    # Remove the redoc.leaf file
    if os.path.exists(redoc_leaf_file):
        os.remove(redoc_leaf_file)
        rollback_actions.append(f"Removed file: {redoc_leaf_file}")
    else:
        rollback_actions.append(f"File not found (already removed): {redoc_leaf_file}")

    # Remove the redoc directory and its contents
    if os.path.exists(redoc_assets_dir):
        shutil.rmtree(redoc_assets_dir)
        rollback_actions.append(f"Removed directory: {redoc_assets_dir}")
    else:
        rollback_actions.append(f"Directory not found (already removed): {redoc_assets_dir}")

    # Ensure no leftover changes in routes.swift
    if os.path.exists(routes_file):
        with open(routes_file, "r") as file:
            content = file.readlines()
        cleaned_content = [line for line in content if "openapi.yml" not in line and "docs" not in line]
        if len(cleaned_content) != len(content):
            with open(routes_file, "w") as file:
                file.writelines(cleaned_content)
            rollback_actions.append(f"Cleaned routes.swift of references to OpenAPI or ReDoc routes")
        else:
            rollback_actions.append("No OpenAPI or ReDoc references found in routes.swift")

    # Ensure no leftover changes in configure.swift
    if os.path.exists(configure_file):
        with open(configure_file, "r") as file:
            content = file.readlines()
        cleaned_content = [line for line in content if ".leaf" not in line]
        if len(cleaned_content) != len(content):
            with open(configure_file, "w") as file:
                file.writelines(cleaned_content)
            rollback_actions.append(f"Cleaned configure.swift of Leaf configuration")
        else:
            rollback_actions.append("No Leaf configuration found in configure.swift")

    # Output the rollback actions
    print("\nRollback Actions Performed:")
    for action in rollback_actions:
        print(f"- {action}")

    print("\nRollback complete. Your project has been restored to its previous state.")

# Run the rollback
if __name__ == "__main__":
    rollback_redoc_setup()

