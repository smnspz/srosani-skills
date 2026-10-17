---
name: c-cpp-best-practices
description: C/C++ conventions — naming (PascalCase/camelCase), nullptr, const correctness, Doxygen comments, namespace and class layout, safe memory management, and a warnings-as-errors policy. Use when writing, editing, or reviewing C or C++ code.
---

# C/C++ Best Practices

C/C++-specific conventions. Language-agnostic rules (explicit boolean comparisons, early-return `//else` clarity, no banner separators, reserved-identifier avoidance, documenting every symbol, and the gradual migration policy) live in the `coding-standards` skill; this skill covers the C/C++ detail on top of that.

## Null Pointers

In C++ files (`.cpp`, `.hpp`), use `nullptr` instead of `NULL`:

```cpp
// Good
if (ptr == nullptr) { /* handle null */ }
MyObject* obj = nullptr;

// Bad
if (ptr == NULL) { /* handle null */ }
MyObject* obj = NULL;
```

This does not apply to C files (`.c`, `.h`), where `NULL` remains correct.

## Naming Conventions

The C++ style here is heavily inspired by C#. It is not the most orthodox choice for C++, but it is one of the clearest to read.

### PascalCase

Use PascalCase for identifiers with global, namespace, or class scope:

1. Classes and structs
2. Free functions (global, namespace, or function scope)
3. Member variables and member functions (class-level)
4. Enums and their values
5. Namespaces

```cpp
namespace MyNamespace
{

class MyClass
{
public:
    int MemberVariable;
    void MemberFunction();
};

enum class Color
{
    Red,
    Green,
    Blue
};

void FreeFunction();

} // namespace MyNamespace
```

### camelCase

Use camelCase for identifiers with local scope:

1. Local variables (declared inside a function)
2. Local (lambda) functions declared inside a function
3. Function arguments (which have local scope within the function)

```cpp
void ProcessData(int inputSize, const std::string& filePath)
{
    int itemCount = 0;
    auto computeOffset = [](int index) { return index * 2; };
    // ...
}
```

### Output arguments

Function arguments used as output variables are prefixed with `out_` and should preferably be placed as the last arguments of the function:

```cpp
void GetDimensions(const Image& image, int& out_width, int& out_height);
```

### Private/protected members

Prefixing private/protected members with a leading underscore (e.g. `_PrivateVariable`) is **deprecated**: identifiers starting with an underscore followed by an uppercase letter (`_Foo`) or with double underscores (`__anything`) are reserved by the C++ standard.

When disambiguation is needed (e.g. between a private member and its accessor), append a trailing underscore to the private member name:

```cpp
class Sensor
{
public:
    int Temperature() const { return Temperature_; }

private:
    int Temperature_;   // Good: trailing underscore
    // int _Temperature; // Deprecated: leading underscore
};
```

### Include guards

Old-style include guards using double leading/trailing underscores (e.g. `__PROJECT_METADATA__PACKET__HPP__`) are **deprecated** because they use reserved identifiers. The **preferred format** is:

```
PROJECT_NAME_FILE_NAME_EXTENSION_
```

Examples:

```cpp
#ifndef PROJECT_UNIT_TESTING_H_
#define PROJECT_UNIT_TESTING_H_

// ...

#endif //!PROJECT_UNIT_TESTING_H_
```

```cpp
#ifndef PROJECT_METADATA_PACKET_H_
#define PROJECT_METADATA_PACKET_H_

// ...

#endif //!PROJECT_METADATA_PACKET_H_
```

## Const Correctness

Strictly enforce `const` wherever possible:

- Mark member functions `const` if they do not modify the object's state.
- Declare local variables `const` when they are not reassigned.
- Pass function arguments by `const&` unless they need to be modified or are trivially copyable scalars.
- Use `const` on pointers (`const int*`, `int* const`) as appropriate.

```cpp
// Good
const int maxRetries = 5;
void PrintName(const std::string& name) const;

// Bad — missing const opportunities
int maxRetries = 5;                // never reassigned
void PrintName(std::string name);  // unnecessary copy, not const
```

This rule applies to both new and existing code being modified.

## Documentation Comments (Doxygen)

Use `///` with classic Doxygen commands (`\brief`, `\param`, `\return`) for documentation comments. Do **not** use XML-style tags or Javadoc-style `/** ... */` comments.

### Functions and methods

```cpp
/// \brief Initializes the module context for the specified device.
/// \param context Pointer to the module context.
/// \return 0 on success, negative error code on failure.
int InitializeContext(ModuleContext *context);
```

### Classes and structs

```cpp
/// \brief Wraps a module handle for RAII-based lifetime management.
class ModuleHandle final
{
    // ...
};
```

### Enum values and member variables

Use a `/// \brief` comment above each enum value and each member variable:

```cpp
enum class ReturnCode
{
    /// \brief Operation completed successfully.
    Ok = 0,

    /// \brief A generic error occurred.
    GenericError = -1,

    /// \brief An invalid argument was passed.
    InvalidArg = -2
};
```

```cpp
/// \brief Name of the module to load.
std::string ModuleName_;
```

### C headers

The same `///` style applies to C headers (`.h`). For `extern "C"` function declarations, place the doc comment above the declaration:

```c
/// \brief Initializes the module context.
EXPORT_VISIBILITY
int initialize_context(ModuleContext *);
```

## Nested Namespaces

When nesting namespaces, use the C++17 nested namespace definition: put the names on one line separated by `::`, with the opening brace on the next line and a single closing brace with no closing comment. The older `namespace A { namespace B` form does not survive brace reformatting — an Allman-style formatter moves each opening brace onto its own line, silently turning it into the form this rule rejects.

```cpp
// Good
namespace MyLibrary::Test
{

    // ...

}
```

```cpp
// Bad — one namespace per line, with separate braces
namespace MyLibrary
{
namespace Test
{
    // ...
}
}
```

## Struct and Class Layout

Structs and classes use explicit access modifiers (`public:`, `private:`, `protected:`) even when the default would suffice (e.g. `public` in a `struct`). Each access modifier section is followed by a blank line before its members, and members within a section are separated by blank lines for readability.

### Constructor and initializer list

The constructor signature ends with ` :` on the same line, followed by the initializer list on the next line (indented). The body `{ }` goes on its own line. Short initializer lists can go on one line; long ones use one item per line.

```cpp
// Good — short initializer list on one line
struct AssertionResult
{
public:

    bool Passed;

    std::string Message;

    std::string File;

    int Line;

public:

    AssertionResult(bool passed, const std::string& message, const std::string& file, int line) :
        Passed(passed), Message(message), File(file), Line(line)
    { }
};
```

```cpp
// Good — long initializer list, one per line
MyClass(const std::string& veryLongParameterName, int anotherParameter, double thirdOne) :
    VeryLongMemberName_(veryLongParameterName),
    AnotherMember_(anotherParameter),
    ThirdMember_(thirdOne)
{ }
```

### Private members

Private members are placed in a `private:` section (followed by a blank line), with each member separated by a blank line.

```cpp
class TestContext
{
public:

    bool Passed() const { return !Failed_; }

private:

    std::vector<AssertionResult> Assertions_;

    bool Failed_ = false;
};
```

## Memory Management

Prefer the project's own allocation wrappers over raw `malloc`/`calloc`/`realloc`/`free`. Good wrappers add memory tracing and safer variants. If the project provides none, apply the patterns below directly.

### Allocation

- Use the project's checked `malloc`/`calloc` wrappers instead of the raw calls.
- Prefer a zero-initializing (`calloc`-style) allocation when the buffer may be read before every byte is written.

### Reallocation

- Prefer a **safe realloc** that takes the address of the pointer (`void**`) and leaves the original pointer unchanged on failure, returning a failure indicator. This avoids the classic leak where the only pointer to a buffer is overwritten by `NULL`.
- Use a **realloc-and-zero** variant when the newly added region must start zeroed.
- Use **element-sized, length-tracking** variants when growing arrays, so the element size and the element count stay in sync.

### Deallocation

- Prefer a **free-and-null** wrapper that frees the buffer and sets the pointer to `NULL`, preventing use-after-free and double-free.

### Safe realloc pattern

When no safe variant is available, always reallocate through a temporary pointer so the original buffer stays reachable on failure:

```c
void *tmp = realloc(ptr, new_size);
if (tmp == NULL) {
    // handle error — ptr is still valid
    free(ptr);
    return ERROR;
}
ptr = tmp;
```

## Compiler Warnings Policy

### Warnings are errors

Build with `-Werror`: **all warnings are treated as compilation errors**. Any code that produces a warning fails the build.

### Common warnings to watch for

- **`-Wstringop-truncation`**: GCC warns when `strncpy` copies from a source whose declared size equals the destination size (it may not null-terminate). This frequently triggers when copying between fixed-size fields of equal size. Suppress locally with `#pragma GCC diagnostic ignored "-Wstringop-truncation"` when the truncation is intentional and a manual null-termination follows.
- **`-Wformat-truncation`**: GCC warns when `snprintf` output may be truncated because the format string could produce more characters than the destination buffer. Suppress locally when truncation is acceptable by design.
- **`-Wdeprecated-declarations`**: triggered when calling a function marked with `__attribute__((deprecated(...)))`. Suppress locally with `#pragma GCC diagnostic ignored "-Wdeprecated-declarations"` when the deprecated call is intentional (e.g. internal/legacy usage within the same library).

### Suppression pattern

Always use the push/pop pattern to limit the scope of suppression, and keep the suppressed region as small as possible — ideally just the offending lines:

```c
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wstringop-truncation"
// ... code that triggers the warning ...
#pragma GCC diagnostic pop
```

### Before submitting code

Verify that new or modified code compiles cleanly. If a warning is unavoidable due to the nature of the operation (e.g. intentional truncation in a fixed-size copy), suppress it explicitly with the minimal scope.
