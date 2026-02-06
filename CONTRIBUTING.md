# Contributing to Nudge

## Philosophy

Nudge is an awareness tool, not a security product. Contributions that expand scope beyond clipboard awareness will be rejected.

## Development rules

1. No external dependencies. Apple frameworks only.
2. No clipboard content is ever stored, logged, or transmitted.
3. Every detection heuristic must be documented with its limitations.
4. No feature may increase alert frequency without a corresponding rate-limiting mechanism.
5. Tests are required for all detection and filtering logic.

## Accepted contributions

- **Detection improvements** -- better heuristics for identifying unexpected clipboard access
- **UX refinements** -- calmer, less intrusive alert presentation
- **Allowlist additions** -- commonly used apps that should be allowlisted by default
- **Bug fixes** -- with reproduction test cases
- **Documentation** -- clarifying limitations and honest scope

## Rejected contributions

- Features that store or transmit clipboard contents
- Network connectivity of any kind
- Machine learning or probabilistic classifiers
- Enterprise or compliance features
- Anything that makes Nudge louder or more intrusive

## Building

```
make build    # debug build
make test     # run tests
make lint     # run swiftlint
make app      # create .app bundle
```

## Code style

- SwiftLint enforced (see .swiftlint.yml)
- `///` doc comments on all public types and methods
- `// MARK: -` sections in view files
- `private` for internal methods
- `final class` where inheritance is not needed
