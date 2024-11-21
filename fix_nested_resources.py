import os
import shutil

# Paths
ROOT_DIR = os.getcwd()
CORRECT_RESOURCES_DIR = os.path.join(ROOT_DIR, "Sources", "App", "Resources")
CORRECT_VIEWS_DIR = os.path.join(CORRECT_RESOURCES_DIR, "Views")
INCORRECT_RESOURCES_DIR = os.path.join(CORRECT_RESOURCES_DIR, "Sources", "App", "Resources")
PACKAGE_FILE = os.path.join(ROOT_DIR, "Package.swift")

# Step 1: Ensure Correct Directories Exist
os.makedirs(CORRECT_VIEWS_DIR, exist_ok=True)

# Step 2: Move Misplaced Resources to Correct Location
if os.path.exists(INCORRECT_RESOURCES_DIR):
    for root, dirs, files in os.walk(INCORRECT_RESOURCES_DIR):
        for file in files:
            src_file = os.path.join(root, file)
            relative_path = os.path.relpath(root, INCORRECT_RESOURCES_DIR)
            dest_dir = os.path.join(CORRECT_RESOURCES_DIR, relative_path)
            os.makedirs(dest_dir, exist_ok=True)
            shutil.move(src_file, os.path.join(dest_dir, file))
    print(f"Moved resources from {INCORRECT_RESOURCES_DIR} to {CORRECT_RESOURCES_DIR}.")
    shutil.rmtree(os.path.join(CORRECT_RESOURCES_DIR, "Sources"))
else:
    print(f"No nested resources found at {INCORRECT_RESOURCES_DIR}.")

# Step 3: Update Package.swift File
if os.path.exists(PACKAGE_FILE):
    with open(PACKAGE_FILE, "r") as file:
        package_content = file.readlines()

    # Find and update resources block
    updated_content = []
    resources_updated = False
    for line in package_content:
        if ".process(\"Sources/App/Sources/App/Resources" in line:
            # Skip incorrect entries
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

# Step 4: Exclude Unhandled Files in Package.swift
EXCLUDE_FILES = [
    ".build/checkouts/leaf-kit/Sources/LeafKit/Docs.docc",
    ".build/checkouts/swift-algorithms/Sources/Algorithms/Documentation.docc",
]

if os.path.exists(PACKAGE_FILE):
    with open(PACKAGE_FILE, "r") as file:
        package_content = file.readlines()

    # Add exclusions if not already present
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

print("Nested resource issues fixed. Rebuild your project using:")
print("swift package clean && swift package update && swift build && swift run")

