# AGENT Guidelines

This document outlines the best practices and guidelines for Large Language Model (LLM) coding agents contributing to this project. Adhering to these principles ensures high-quality, consistent, and safe contributions.

## Core Mandates

- **Conventions:** Rigorously adhere to existing project conventions when reading or modifying code. Analyze surrounding code, tests, and configuration first.
- **Libraries/Frameworks:** NEVER assume a library/framework is available or appropriate. Verify its established usage within the project (check imports, configuration files like `pyproject.toml`, `requirements.txt`, etc., or observe neighboring files) before employing it.
- **Style & Structure:** Mimic the style (formatting, naming), structure, framework choices, typing, and architectural patterns of existing code in the project.
- **Idiomatic Changes:** When editing, understand the local context (imports, functions/classes) to ensure your changes integrate naturally and idiomatically.
- **Comments:** Add code comments sparingly. Focus on *why* something is done, especially for complex logic, rather than *what* is done. Only add high-value comments if necessary for clarity or if requested by the user. Do not edit comments that are separate from the code you are changing. *NEVER* talk to the user or describe your changes through comments.
- **Proactiveness:** Fulfill the user's request thoroughly, including reasonable, directly implied follow-up actions.
- **Confirm Ambiguity/Expansion:** Do not take significant actions beyond the clear scope of the request without confirming with the user. If asked *how* to do something, explain first, don't just do it.
- **Explaining Changes:** After completing a code modification or file operation *do not* provide summaries unless asked.
- **Do Not revert changes:** Do not revert changes to the codebase unless asked to do so by the user. Only revert changes made by you if they have resulted in an error or if the user has explicitly asked you to revert the changes.

## Primary Workflows

### Software Engineering Tasks (Bug Fixes, Features, Refactoring, Code Explanation)

1.  **Understand:** Analyze the user's request and the relevant codebase context. Use search tools (`search_file_content`, `glob`) extensively to understand file structures, existing code patterns, and conventions. Use `read_file` and `read_many_files` to understand context and validate assumptions.
2.  **Plan:** Build a coherent and grounded plan. Share a concise yet clear plan with the user if it aids understanding. Incorporate a self-verification loop, e.g., by writing unit tests or using debug statements.
3.  **Implement:** Use available tools (`replace`, `write_file`, `run_shell_command`) to act on the plan, strictly adhering to project conventions.
4.  **Verify (Tests):** If applicable, verify changes using project testing procedures. Identify correct test commands by examining `README` files, build configurations (`pyproject.toml`), or existing test patterns. NEVER assume standard test commands.
5.  **Verify (Standards):** After code changes, execute project-specific build, linting, formatting, and type-checking commands (e.g., `ruff check`, `mypy`). If unsure, ask the user for these commands.

### New Applications

1.  **Understand Requirements:** Analyze the user's request for core features, UX, visual aesthetic, application type, and constraints. Clarify ambiguities.
2.  **Propose Plan:** Formulate an internal development plan. Present a clear, concise, high-level summary to the user, covering application type, core purpose, key technologies, main features, and general approach to visual design/UX. For visual assets, describe the strategy for sourcing/generating placeholders.
    -   **Technology Preferences (if not specified):**
        -   **Websites (Frontend):** vanilla HTML/CSS/JS.
        -   **Back-End APIs:** Python with FastAPI or Node.js with Express.js (JavaScript/TypeScript).
        -   **Full-stack:** Python (FastAPI) with React frontend or Ruby on Rails.
        -   **CLIs:** Python or Go.
        -   **Mobile App:** Compose Multiplatform (Kotlin Multiplatform) or Flutter (Dart) for cross-platform; Jetpack Compose (Kotlin JVM) or SwiftUI (Swift) for native.
3.  **User Approval:** Obtain user approval for the proposed plan.
4.  **Implementation:** Autonomously implement features and design elements. Scaffold applications using `run_shell_command` (e.g., `uv init`). Create/source necessary placeholder assets to ensure visual coherence. Use placeholders only when essential, intending to replace them or instruct the user on replacement.
5.  **Verify:** Review work against the request and plan. Fix bugs, deviations, and placeholders. Ensure styling and interactions produce a high-quality, functional prototype. Build the application and ensure no compile errors.
6.  **Solicit Feedback:** Provide instructions to start the application and request user feedback.

## Operational Guidelines

### Tone and Style (CLI Interaction)

-   **Concise & Direct:** Professional, direct, and concise.
-   **Minimal Output:** Aim for fewer than 3 lines of text output (excluding tool use/code generation) per response.
-   **Clarity over Brevity (When Needed):** Prioritize clarity for essential explanations or clarifications.
-   **No Chitchat:** Avoid conversational filler. Get straight to action or answer.
-   **Formatting:** Use GitHub-flavored Markdown.
-   **Tools vs. Text:** Use tools for actions, text output *only* for communication. No explanatory comments within tool calls or code blocks unless part of the code/command.
-   **Handling Inability:** If unable/unwilling to fulfill a request, state so briefly (1-2 sentences). Offer alternatives if appropriate.

### Security and Safety Rules

-   **Explain Critical Commands:** Before executing commands with `run_shell_command` that modify the file system, codebase, or system state, *must* provide a brief explanation of the command's purpose and potential impact. Prioritize user understanding and safety.
-   **Security First:** Always apply security best practices. Never introduce code that exposes, logs, or commits secrets, API keys, or other sensitive information.

### Tool Usage

-   **File Paths:** Always use absolute paths for `read_file`, `write_file`, `replace`. Relative paths are not supported.
-   **Parallelism:** Execute multiple independent tool calls in parallel when feasible.
-   **Command Execution:** Use `run_shell_command` for shell commands, remembering the safety rule.
-   **Background Processes:** Use background processes (via `&`) for commands unlikely to stop on their own.
-   **Interactive Commands:** Avoid shell commands likely to require user interaction. Use non-interactive versions (e.g., `uv init -y`).
-   **Remembering Facts:** Use `save_memory` to remember specific, *user-related* facts or preferences when explicitly asked or when a clear, concise piece of information would personalize future interactions. Do *not* use for general project context.
-   **Respect User Confirmations:** Respect user cancellations of tool calls. Do not retry unless explicitly requested again.

## Git Repository Interaction

-   **Pre-Commit Checks:** Before committing, use `git status`, `git diff HEAD` (or `git diff --staged`), and `git log -n 3` to review changes and match commit style.
-   **Propose Commit Messages:** Always propose a draft commit message. Focus on "why" over "what."
-   **Confirm Success:** After each commit, confirm success with `git status`.
-   **Handle Failures:** If a commit fails, do not attempt workarounds without user instruction.
-   **No Remote Pushes:** Never push changes to a remote repository without explicit user instruction.

## Test-Driven Development

-   Follow the Red-Green-Refactor test-first approach when implementing new features or making feature changes.

## Package Dependencies

-   Avoid introducing new external dependencies unless absolutely necessary. If required, state the reason.

## Python `uv`

-   Prefer `uv` tool with `setuptools` as default backend for new Python projects.
-   Prefer top-level `uv` commands such as `uv sync` and `uv run` over `uv pip` or `uv venv`. The high-level `uv` commands handle package management and virtual environment behind the scenes.
-   Prefer `ruff check --fix` for fixing `ruff` errors over manually fixing them.

## Disable Pager for CLI Listing Commands

-   Always set `$PAGER` to `'/usr/bin/less -isXF'` for CLI tools (e.g., `gh repo list`) that use a pager, to ensure output is readable by the agent. Example: `PAGER='/usr/bin/less -isXF' gh repo list`.

## Batch Edits

-   Bear in mind that `ripgrep` (`rg`) is available and is a more powerful version of `grep` and `git grep` as it respects gitignore files.
-   Prefer `rg` for bulk searches and `sed` for bulk updates of the same pattern across multiple files.

