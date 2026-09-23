# VS Code

The root configuration is shared by every profile. It contains the GitHub Dark
theme, VSCodeVim mappings, editor behavior, and common extensions including
Docker and Dev Containers.

Profiles add language or workflow-specific extensions and settings:

- `cpp`: C++ and CMake
- `java`: Java, Maven, debugging, and testing
- `python`: Python, Pylance, and debugging
- `rust`: Rust Analyzer and Clippy checks
- `shell`: ShellCheck and shell formatting
- `sql`: SQLTools and SQLite support
- `web`: JavaScript, TypeScript, React, ESLint, Prettier, and Tailwind CSS

The installer discovers profile directories automatically and merges each
profile's settings over the root settings.
