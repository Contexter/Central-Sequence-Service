import os
import shutil

# Paths
ROOT_DIR = os.getcwd()
RESOURCES_SRC = os.path.join(ROOT_DIR, "Resources")
APP_RESOURCES_DIR = os.path.join(ROOT_DIR, "Sources", "App", "Resources")
VIEWS_SRC = os.path.join(RESOURCES_SRC, "Views")
APP_VIEWS_DIR = os.path.join(APP_RESOURCES_DIR, "Views")
OPENAPI_SRC = os.path.join(RESOURCES_SRC, "openapi.yml")
OPENAPI_DEST = os.path.join(APP_RESOURCES_DIR, "openapi.yml")
PACKAGE_FILE = os.path.join(ROOT_DIR, "Package.swift")

# Step 1: Ensure Resources Directory Exists in App
os.makedirs(APP_VIEWS_DIR, exist_ok=True)

# Step 2: Move Views and openapi.yml to Correct Locations
if os.path.exists(VIEWS_SRC):
    for file in os.listdir(VIEWS_SRC):
        src_file = os.path.join(VIEWS_SRC, file)
        dest_file = os.path.join(APP_VIEWS_DIR, file)
        shutil.move(src_file, dest_file)
    print(f"Moved Views to {APP_VIEWS_DIR}")
else:
    print(f"Warning: {VIEWS_SRC} does not exist.")

if os.path.exists(OPENAPI_SRC):
    shutil.move(OPENAPI_SRC, OPENAPI_DEST)
    print(f"Moved openapi.yml to {OPENAPI_DEST}")
else:
    print(f"Warning: {OPENAPI_SRC} does not exist.")

# Step 3: Update Package.swift File
if os.path.exists(PACKAGE_FILE):
    with open(PACKAGE_FILE, "r") as file:
        package_content = file.readlines()

    # Find and update resources block
    updated_content = []
    resources_updated = False
    for line in package_content:
        if ".process(\"Resources" in line:
            if "Resources/Views" in line or "Resources/openapi.yml" in line:
                # Skip old resource entries
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

print("Resource issues fixed. Rebuild your project using:")
print("swift package update && swift build && swift run")

