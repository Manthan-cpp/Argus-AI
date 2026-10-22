# Contributing to Argus AI

Thank you for your interest in contributing to **Argus AI**! We welcome contributions from developers, researchers, and designers of all skill levels.

---

## Code of Conduct

We are dedicated to providing a welcoming, inclusive, and harassment-free experience for everyone. Please be respectful, constructive, and collaborative in all issues, pull requests, and discussions.

---

## How Can I Contribute?

You can contribute in several ways:
- **Reporting Bugs:** Submit an issue describing unexpected behavior, steps to reproduce, and environment details.
- **Suggesting Enhancements:** Open an issue outlining new features, architectural improvements, or UX enhancements.
- **Submitting Pull Requests:** Fix known bugs, add test coverage, improve documentation, or implement approved feature requests.

---

## Project Architecture

Argus AI is engineered as a unified Full-Stack Dart ecosystem cleanly organized into three core packages:

| Directory | Role | Stack |
| :--- | :--- | :--- |
| `argus/argus_engine/` | Core geometric ray-casting, Jordan curve algorithms, and natural language rule parser | Pure Dart (zero external dependencies) |
| `argus/argus_server/` | Real-time WebSocket streaming, PostgreSQL persistence, and escalation countdown timers | High-concurrency Dart backend |
| `argus/argus_flutter/` | Tactical control room interface, CanvasKit video rendering, and polygon zone editing | Flutter (Web & Desktop) |

---

## Development Setup

### Prerequisites
- **Flutter SDK:** Version 3.24+ (`stable` channel)
- **Dart SDK:** Version 3.5+
- **PostgreSQL:** Version 15+ (for local backend persistence)
- **Google Chrome:** (for Flutter Web with CanvasKit rendering)

### 1. Clone the Repository
```bash
git clone https://github.com/Manthan-cpp/Argus-AI.git
cd "Argus AI"
```

### 2. Install Package Dependencies
Install dependencies for each workspace package:
```bash
# Core Geometry Engine
cd argus/argus_engine
dart pub get

# Backend Server
cd ../argus_server
dart pub get

# Flutter Control Room
cd ../argus_flutter
flutter pub get
```

---

## Running Tests

All pull requests must pass automated unit and widget tests before being merged.

### 1. Pure Engine Unit Tests
The geometric algorithms and rule parser can be tested in sub-seconds:
```bash
cd argus/argus_engine
dart test
```

### 2. Flutter Widget & Integration Tests
```bash
cd argus/argus_flutter
flutter test
```

---

## Coding Standards

- **Dart Style Guide:** Follow the official [Effective Dart](https://dart.dev/effective-dart) guidelines.
- **Formatting:** Format all Dart code before committing:
  ```bash
  dart format .
  ```
- **Static Analysis:** Ensure zero analyzer warnings or errors:
  ```bash
  dart analyze
  ```
- **Architectural Isolation:** Keep `argus_engine` strictly free of platform-specific dependencies (such as `dart:io` or Flutter packages) so it remains runnable anywhere.

---

## Pull Request Workflow

1. **Fork and Branch:** Fork the repository and create a feature branch off `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. **Make Focused Changes:** Keep changes small, modular, and well-tested.
3. **Write Meaningful Commits:** Use clear, concise commit messages describing *what* and *why*.
4. **Run Local Verification:** Run tests and static analysis across modified packages.
5. **Open a Pull Request:**
   - Link any related issues.
   - Provide a clear summary of your changes.
   - Include screenshots or video recordings for UI changes in `argus_flutter`.

---

## License

By contributing to Argus AI, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).
