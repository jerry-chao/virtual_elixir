<!--
S Y N C  I M P A C T  R E P O R T

Version Change: N/A → 1.0.0 (initial creation)
Project: Virtual Elixir (Elixir & Python)

Modified Principles: N/A (all new)

Added Sections:
  - Core Principles (5 principles)
  - Language-Specific Standards
  - Quality Gates & Standards
  - Development Workflow

Removed Sections: N/A

Templates Status:
  ✅ .specify/templates/plan-template.md - Constitution Check section aligns with all principles
  ✅ .specify/templates/spec-template.md - Independent testability requirement aligns with Test-First principle
  ✅ .specify/templates/tasks-template.md - Task organization by user story aligns with MVP-First principle
  
Follow-up TODOs: N/A
-->

# Virtual Elixir Constitution

## Core Principles

### I. Test-First Development (NON-NEGOTIABLE)

Every feature MUST be developed using Test-Driven Development (TDD): Tests written → Approved → Tests fail → Then implement → Refactor.

- **Elixir**: Use ExUnit for tests, write `@tag :integration` for integration tests
- **Python**: Use pytest for tests, write fixtures for shared test setup
- Red-Green-Refactor cycle is strictly enforced - no implementation without failing tests first
- Tests MUST be independent and runnable in any order
- Code coverage MUST be maintained above 80% for new features

**Rationale**: TDD ensures code correctness, facilitates refactoring, and provides living documentation. Both Elixir and Python have mature testing frameworks that make TDD natural.

### II. MVP-First Development

Every feature starts with the smallest independently testable implementation that delivers user value.

- User stories MUST be prioritized (P1, P2, P3) where P1 = MVP-critical
- Each user story MUST be independently implementable, testable, and deployable
- Stop and validate after each user story completes before proceeding
- Avoid features that cannot be independently demonstrated to users
- Document why each story has its priority level

**Rationale**: Incremental delivery reduces risk, enables faster feedback loops, and ensures each deliverable provides measurable value. This applies to both Elixir applications (Supervisor trees, GenServers) and Python APIs/services.

### III. Immutability & Functional Core

Prefer immutable data structures and pure functions. Mutable state MUST be isolated and justified.

- **Elixir**: Leverage immutability by default, use `GenServer` for state management when needed
- **Python**: Use dataclasses/frozen classes, type hints with `@final`, minimize global state
- Pure functions preferred over stateful operations
- Side effects (IO, database, network) MUST be isolated at system boundaries
- Document any exceptions to immutability with clear rationale

**Rationale**: Immutability reduces bugs, enables concurrency safety, and makes code predictable. Both languages support this pattern effectively.

### IV. Observable & Debuggable

All code MUST be debuggable in production with structured logging and metrics.

- **Elixir**: Use structured logging with metadata, implement telemetry events, expose Ecto query logs in development
- **Python**: Use structured logging (JSON format), implement application metrics, use debugger-friendly exception handling
- Log at appropriate levels (debug, info, warn, error) with context
- Include request IDs in logs for tracing
- Ensure deployment environment has proper monitoring and alerting

**Rationale**: Production issues require visibility. Both Elixir and Python have excellent observability tools (Telemetry/Logger for Elixir, Python logging/metrics libraries).

### V. Documentation as Code

Documentation MUST be co-located with code, kept current, and executable.

- **Elixir**: Use `@doc` attributes for function/module documentation, keep doctests passing
- **Python**: Use docstrings (Google or NumPy style), include type hints, keep examples in docstrings executable
- API endpoints MUST document request/response schemas and error cases
- README files MUST include quickstart examples that actually work
- Update documentation in the same commit as code changes

**Rationale**: Co-located documentation stays relevant and executable documentation prevents rot. Both languages have tools (ExDoc, Sphinx) that generate docs from code.

## Language-Specific Standards

### Elixir Development

- **Dependencies**: Manage via `mix.exs`, pin exact versions in `mix.lock`
- **Testing**: ExUnit for all tests, use `@moduletag` for test organization
- **Documentation**: ExDoc for generated docs, `@doc` attributes required for public functions
- **Code Style**: Follow community standards (mix format), use pipeline operator (`|>`)
- **Error Handling**: Use `{:ok, result}` / `{:error, reason}` tuples, pattern match errors
- **Concurrency**: Use Supervisor trees for fault tolerance, GenServer for state, Task for parallel operations

### Python Development

- **Dependencies**: Manage via `requirements.txt` or `pyproject.toml`, use virtual environments
- **Testing**: pytest for all tests, use fixtures for shared setup, parametrize similar tests
- **Documentation**: Google-style or NumPy-style docstrings, include type hints
- **Code Style**: Follow PEP 8, use `black` for formatting, `mypy` for type checking
- **Error Handling**: Use exceptions appropriately, create custom exception classes for domains
- **Type Safety**: Use type hints for public APIs, enable mypy strict mode

## Quality Gates & Standards

Every commit MUST pass these gates before merging:

- [ ] All tests pass (unit, integration, contract)
- [ ] Code coverage maintained above 80%
- [ ] Linting passes (Credo for Elixir, ruff/flake8 for Python)
- [ ] Formatting applied (mix format for Elixir, black/isort for Python)
- [ ] Type checking passes (mypy for Python if applicable)
- [ ] Documentation updated and accurate
- [ ] No obvious performance regressions
- [ ] Security vulnerabilities scanned and addressed

**Violations**: If a gate fails, explain the violation and get explicit approval before proceeding. Constitution violations require documentation of why simpler alternatives were rejected.

## Development Workflow

1. **Understand**: Study existing patterns in codebase, find 3 similar implementations
2. **Test**: Write test first (red phase)
3. **Implement**: Minimal code to pass (green phase)
4. **Refactor**: Clean up with tests passing
5. **Document**: Update documentation in same commit
6. **Commit**: Clear commit message linking to plan/user story

Stop after 3 failed attempts and reassess approach. Document what was tried, why it failed, research alternatives, question fundamentals, try different angle.

## Governance

- Constitution supersedes all other development practices
- All PRs/reviews MUST verify constitution compliance
- Amendments to this constitution require documentation, approval, and migration plan
- Use `.specify/templates/` for planning and documentation workflows
- Complexity violations MUST be justified in plan documents

**Version**: 1.0.0 | **Ratified**: 2025-01-15 | **Last Amended**: 2025-01-15
