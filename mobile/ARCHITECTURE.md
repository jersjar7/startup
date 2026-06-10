# Mobile architecture

Clean architecture. Dependencies point **inward**; the domain knows nothing about
React, storage, or the network. Each file holds one concept (one class/interface
where practical; tiny cohesive value types are grouped).

```
src/
  core/            cross-cutting kernel — theme, Result. No business rules.
  domain/          INNERMOST. Pure TS, zero framework imports.
    entities/      problem, card, mastery, session, plan, review…
    repositories/  PORTS — interfaces the outer layers implement.
    services/      domain service PORTS — scheduling, pacing, mastery policy.
    usecases/      application rules — one use case per file.
  data/            ADAPTERS. Implements domain ports.
    sources/       content (bundled) + storage (AsyncStorage) + (future) remote.
    repositories/  concrete repositories → depend on sources + domain ports.
    services/      concrete scheduler / pacing / mastery policies.
  presentation/    OUTERMOST. React Native only.
    ui/            design-system primitives (visual-language.md tokens).
    navigation/    tab + stack navigators.
    features/      one folder per feature: Screen + view-model + components.
  di/              composition root — builds sources→repos→usecases, injects them.
```

## The dependency rule
- `presentation` and `data` may import from `domain`.
- `domain` imports from **nothing** outside itself (not React, not AsyncStorage).
- Concrete wiring happens **only** in `di/container.ts` (the composition root).
- Screens never `new` a repository — they receive use cases via `useUseCases()`.

## Why this shape
- **Swap-able infrastructure.** The bundled content source can become a remote
  API, AsyncStorage can become SQLite — domain + presentation don't change.
- **Testable core.** Use cases and policies are pure; test without RN.
- **Shared brain.** The domain mirrors the web's model (one bank, one
  spaced-repetition state) so logic can later be lifted into a shared package.
- **Scales by adding folders, not growing files.** New feature = new
  `features/<x>/` folder; new data = new `sources/<x>/`. Files stay short.

## Conventions
- One concept per file. Group only tightly-coupled tiny value types.
- Entities are immutable (`readonly`). No methods with side effects in domain.
- Async boundaries return `Promise`; recoverable failures use `core/result`.
- Path alias `@/*` → `src/*` (Expo Metro + tsconfig resolve it).
- UI reads tokens from the theme — never hard-codes hex (see visual-language.md).
