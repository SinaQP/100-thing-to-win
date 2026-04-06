# Architecture (Phase 1)

## Approach
Feature-first clean architecture:
- `presentation`: UI, providers, routing-aware state
- `domain`: entities, repository contracts, use cases
- `data`: datasource + repository implementations
- `core`: app-wide services (theme, db, routing, shared widgets)

## Why
- Keeps features isolated and scalable
- Allows unit testing of domain without Flutter UI dependencies
- Supports offline-first by putting local storage behind repository interfaces

## Offline Strategy (v1)
- SQLite (`sqflite`) local database
- No network/auth dependencies
- Backup import/export interfaces prepared in settings module

## State Management
- `flutter_riverpod` for dependency injection + async state

## Navigation
- `go_router` with shell navigation and 5-tab bottom nav

## Theming
- Material 3 + custom color/typography/motion tokens
- Persistent theme mode using `shared_preferences`
