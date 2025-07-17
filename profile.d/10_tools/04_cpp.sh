# C++ development tools configuration

### CMake ###
# Compiler diagnostics on by default
export CMAKE_COLOR_DIAGNOSTICS="ON"

### Ninja ###
if command -v ninja >/dev/null 2>&1; then
    # Support for ninja status
    if [ "$(ninja --version | cut -d '.' -f 2)" -gt "10" ]; then
        export NINJA_STATUS=$(echo -e "[%f/%t %p %e] ")
    fi

    # Use ninja as default generators in CMake and Conan CMake generator
    export CMAKE_GENERATOR="Ninja"
    export CONAN_CMAKE_GENERATOR="Ninja"
fi

### vcpkg ###
export VCPKG_ROOT="$HOME/vcpkg"
if [ -d "$VCPKG_ROOT" ]; then
    export PATH="$VCPKG_ROOT:$PATH"
fi