import os

def clean_vapor_project(base_dir):
    """
    Cleans a Vapor project by removing references to 'swift new' default components
    like TodoController and CreateTodo, based on the given project structure.
    """
    # Define paths based on your project structure
    routes_file = os.path.join(base_dir, "Sources/App/routes.swift")
    configure_file = os.path.join(base_dir, "Sources/App/configure.swift")
    controllers_dir = os.path.join(base_dir, "Sources/App/Controllers")
    migrations_dir = os.path.join(base_dir, "Sources/App/Migrations")

    # Helper function to clean files
    def clean_file(file_path, patterns_to_remove):
        if not os.path.exists(file_path):
            print(f"File not found: {file_path}")
            return
        with open(file_path, "r") as file:
            lines = file.readlines()

        # Remove lines containing any of the specified patterns
        cleaned_lines = [
            line for line in lines if not any(pattern in line for pattern in patterns_to_remove)
        ]

        with open(file_path, "w") as file:
            file.writelines(cleaned_lines)
        print(f"Cleaned file: {file_path}")

    # Clean routes.swift
    print("Cleaning routes.swift...")
    clean_file(
        routes_file,
        patterns_to_remove=["TodoController", "register(collection:"]
    )

    # Clean configure.swift
    print("Cleaning configure.swift...")
    clean_file(
        configure_file,
        patterns_to_remove=["CreateTodo", "app.migrations.add"]
    )

    # Remove default controller files
    print("Removing default controller files...")
    if os.path.exists(controllers_dir):
        for file_name in os.listdir(controllers_dir):
            if "Todo" in file_name:
                file_path = os.path.join(controllers_dir, file_name)
                os.remove(file_path)
                print(f"Removed file: {file_path}")

    # Remove default migration files
    print("Removing default migration files...")
    if os.path.exists(migrations_dir):
        for file_name in os.listdir(migrations_dir):
            if "Todo" in file_name:
                file_path = os.path.join(migrations_dir, file_name)
                os.remove(file_path)
                print(f"Removed file: {file_path}")

    print("Cleanup completed. Please ensure the project compiles by running:")
    print("swift build")


# Run the script
if __name__ == "__main__":
    # Define the base directory of your Vapor project
    project_base_dir = os.getcwd()  # Current directory
    clean_vapor_project(project_base_dir)
