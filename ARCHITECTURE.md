# NexaCalc — Architecture Summary

Overview
- Flutter app (Android) using Riverpod for state management.
- Exact arithmetic using `decimal` and `rational` packages; no floating-point doubles.
- Local history persisted in SQLite (`sqflite`) with FTS5 for search.
- Voice input and on-device LLM are architected as pluggable runtime implementations (stubs present for local dev).
- In-app purchase gating (`ProUpgradeImpl`) and ad management (`AdManagerImpl`) implemented with simple local persistence for MVP.

Key modules
- `lib/screens/` — UI screens (calculator, history, settings, theme editor, model download dialog).
- `lib/core/engine/` — `DecimalEngineImpl` recursive-descent parser and evaluator.
- `lib/core/db/` — `HistoryDBImpl` with FTS5 and CSV export.
- `lib/core/llm/` — `LLMRuntimeImpl` (downloads, loads model, calls LlamaCpp stub).
- `lib/core/voice/` — `VoiceInputImpl` using `whisper` stub; emits noise level stream.
- `lib/core/nlp/` — `NLProcessorImpl` orchestrates LLM then `RegexFallbackImpl`.
- `lib/core/providers/` — Riverpod providers and notifiers for app wiring.

Extensibility points
- Replace `core/stubs/*` with production platform/FFI bindings for Whisper and llama.cpp.
- Replace `ProUpgradeImpl` local persistence with server-side receipt validation for secure gating.
- Swap `AdManagerImpl` placeholder with real Ad SDK integration (AdMob/AdManager) behind `AdManager` interface.

Next recommended steps
1. Integrate on-device Whisper & LLM runtimes (FFI or platform channels). Provide model download UI (done).
2. Implement secure receipt validation server or use Play-integrated validation APIs.
3. Run property-based tests for `DecimalEngineImpl` to verify arithmetic invariants.
4. Add accessibility audit and performance profiling on target devices.
