---
name: 'rzlv-extract-methods-for-clarity'
description: 'Review Flutter/Dart code for large methods and repeated patterns that should be broken into smaller, well-named private methods or getters to improve readability and testability.'
allowed-tools:
  - edit/editFiles
  - edit/createFile
  - github/*
---

# rzlv: Extract Methods for Clarity

## Purpose

Flag large methods, deeply nested conditionals, and repeated code patterns that reduce readability and make testing harder. Recommend well-named private methods or getters that express *what* is happening rather than *how*.

## When to Apply

Trigger this skill when a PR introduces or modifies:
- Methods longer than ~30–40 lines
- `if/else` blocks containing complex logic in both branches
- Repeated code patterns across multiple call sites
- Inline boolean conditions that require significant mental parsing
- C++ or Dart functions with duplicated initialization patterns

## Key Practices

1. **Extract large if/else branches into focused methods**:
   ```dart
   // Before: 20+ lines inline per branch
   if (hasNewline) { /* complex logic */ } else { /* different complex logic */ }

   // After: Self-documenting extraction
   final Path path = hasNewline
       ? _createMultilineIndicatorPath()
       : _createSingleLineIndicatorPath();
   ```

2. **Extract repeated initialization patterns into helper methods**:
   ```cpp
   // Before: Same parameters repeated
   auto data_host_buffer = HostBuffer::Create(allocator, waiter, alignment);
   auto indexes_host_buffer = needsPartition
       ? HostBuffer::Create(allocator, waiter, alignment)
       : data_host_buffer;

   // After: Single helper encapsulates the pattern
   auto [data_host_buffer, indexes_host_buffer] = createHostBuffers();
   ```

3. **Extract inline boolean conditions into descriptive getters**:
   ```dart
   // Before: Requires reading two fields to understand intent
   if (widget.separatorBuilder != null && index.isOdd) { ... }

   // After: Intent is immediately clear
   bool get hasSeparators => widget.separatorBuilder != null;
   bool get isSeparator => hasSeparators && index.isOdd;
   ```

## Review Checklist

- [ ] Are there methods longer than ~35 lines that could be split by responsibility?
- [ ] Do `if/else` branches each contain more than ~5–8 lines of logic?
- [ ] Is the same initialization or computation pattern repeated more than twice?
- [ ] Do inline boolean conditions require more than a single glance to understand?
- [ ] Would extracting a getter or method make the call site self-documenting?

## Output

Raise findings as:
- 🔴 **Blocking** — method is so large it is unmaintainable and hides logic errors
- 🟡 **Important** — extraction would significantly reduce cognitive load and enable unit testing
- 🔵 **Minor** — style-level extraction that would improve readability

