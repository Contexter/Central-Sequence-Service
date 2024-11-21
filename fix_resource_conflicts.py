import os
import shutil

# Define paths
ROOT_DIR = os.getcwd()
APP_DIR = os.path.join(ROOT_DIR, "Sources", "App")
RESOURCES_DIR = os.path.join(APP_DIR, "Resources")
VIEWS_DIR = os.path.join(RESOURCES_DIR, "Views")
NESTED_RESOURCES_DIR = os.path.join(APP_DIR, "Sources", "App", "Resources")
PACKAGE_FILE = os.path.join(ROOT_DIR, "Package.swift")

# Step 1: Ensure correct resource directories exist
os.makedirs(VIEWS_DIR, exist_ok=True)

# Step 2: Move misplaced resources to the correct location
if os.path.exists(NESTED_RESOURCES_DIR):
    for root, dirs, files in os.walk(NESTED_RESOURCES_DIR):
        for file in files:
            src_file = os.path.join(root, file)
            relative_path = os.path.relpath(root, NESTED_RESOURCES_DIR)
            dest_dir = os.path.join(RESOURCES_DIR, relative_path)
            os.makedirs(dest_dir, exist_ok=True)
            shutil.move(src_file, os.path.join(dest_dir, file))
    print(f"Moved resources from {NESTED_RESOURCES_DIR} to {RESOURCES_DIR}.")
    shutil.rmtree(os.path.join(APP_DIR, "Sources"))
else:
    print(f"No nested resources found in {NESTED_RESOURCES_DIR}.")

# Step 3: Update Package.swift file to include only valid resource paths
if os.path.exists(PACKAGE_FILE):
    with open(PACKAGE_FILE, "r") as file:
        package_content = file.readlines()

    # Fix resource declarations
    updated_content = []
    resources_updated = False
    for line in package_content:
        if ".process(\"Sources/App/Resources" in line:
            # Skip incorrect or duplicate resource entries
            continue
        if "resources: [" in line and not resources_updated:
            updated_content.append(line)
            updated_content.append(
                "                .process(\"Sources/App/Resources/Views\"),\n"
            )
            updated_content.append(
                "                .process(\"Sources/App/Resources/openapi.yml\"),\n"
            )
            resources_updated = True
            continue
        updated_content.append(line)

    with open(PACKAGE_FILE, "w") as file:
        file.writelines(updated_content)
    print(f"Updated {PACKAGE_FILE} with correct resource paths.")
else:
    print(f"Error: {PACKAGE_FILE} does not exist.")

# Step 4: Clean up duplicate or unhandled resource declarations
EXCLUDE_FILES = [
    ".build/checkouts/leaf-kit/Sources/LeafKit/Docs.docc",
    ".build/checkouts/swift-algorithms/Sources/Algorithms/Documentation.docc",
]

if os.path.exists(PACKAGE_FILE):
    with open(PACKAGE_FILE, "r") as file:
        package_content = file.readlines()

    exclusions_updated = False
    updated_content = []
    for line in package_content:
        if "exclude: [" in line and not exclusions_updated:
            updated_content.append(line)
            for exclude in EXCLUDE_FILES:
                updated_content.append(f'        "{exclude}",\n')
            exclusions_updated = True
            continue
        updated_content.append(line)

    with open(PACKAGE_FILE, "w") as file:
        file.writelines(updated_content)
    print(f"Added exclusions to {PACKAGE_FILE}.")
else:
    print(f"Error: {PACKAGE_FILE} does not exist.")

print("All resource conflicts resolved. Rebuild your project using:")
print("swift package clean && swift package update && swift build && swift run")

