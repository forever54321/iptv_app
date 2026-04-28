# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter IPTV player targeting **Windows desktop** and **Android TV**. Loads M3U playlists (direct URL or Xtream Codes endpoint), browses channels with category/language sidebar + search, plays via `media_kit` (libmpv-based). Dart SDK `^3.11.0`.

## Common commands

```bash
flutter pub get                 # install dependencies
flutter analyze                 # lint (uses package:flutter_lints/flutter.yaml)
flutter test                    # run tests
flutter test test/widget_test.dart -p name   # run a single test by name

flutter run -d windows          # debug on Windows
flutter run -d android          # debug on Android / Android TV
flutter build windows --release # build Windows release into build/windows/x64/runner/Release/
flutter build apk --release     # build Android APK
```

Windows installer: after `flutter build windows --release`, compile `installer/setup.iss` with Inno Setup. Note that `setup.iss` contains hardcoded `C:\Users\szaka\iptv_app\...` paths that must be edited for any other build environment.

### Hive code generation

`lib/models/playlist_source.g.dart` is generated (`@HiveType` adapters). The current file was hand-written / committed and there is **no `build_runner` / `hive_generator` in `pubspec.yaml`**. If you change `PlaylistSource` or `PlaylistType` fields, either edit `playlist_source.g.dart` by hand to match, or add `build_runner` + `hive_generator` as dev_dependencies and run `dart run build_runner build --delete-conflicting-outputs`. Hive `typeId`s in use: `0` = `PlaylistType`, `1` = `PlaylistSource` — do not reuse these IDs and do not renumber existing `@HiveField` indices (breaks stored playlists in users' Hive boxes).

## Architecture

### Entry point and platform branching

`lib/main.dart` initializes `MediaKit`, `Hive`, and `StorageService` (which registers Hive adapters and opens the `playlists` box) **before** `runApp`. It then branches per platform:
- Desktop (Windows/Linux/macOS): configures `window_manager` (1280×720, min 800×500, "IPTV Player" title).
- Android: forces landscape orientation and `SystemUiMode.immersiveSticky` for TV.

The whole app is wrapped in `ProviderScope` (Riverpod). `lib/app.dart` is just a `MaterialApp.router` using `AppTheme.dark` (Material 3, deep-purple seed, dark scaffold) and `appRouter`.

### Routing (`lib/core/router.dart`)

Three flat `go_router` routes — no nesting, no shells:
- `/` → `HomeScreen` (playlist sources list)
- `/channels` → `ChannelsScreen` (sidebar + grid)
- `/player` → `PlayerScreen`, expects `extra: {'initialIndex': int}`

### State: provider chain (Riverpod)

The whole UI is a derivation of one `AsyncNotifier` → a few `Provider`s. Understand this chain before touching state code:

```
playlistSourcesProvider (AsyncNotifier, persisted via StorageService/Hive)
        │
        └─► activePlaylistProvider (Provider, picks isActive==true)
                    │
                    └─► channelListProvider (FutureProvider, fetches + parses M3U)
                                │
                                ├─► categoriesProvider (groups + tvg-language buckets)
                                │
                                └─► filteredChannelsProvider
                                        ▲           ▲
                                        │           │
                          selectedCategoryProvider  searchQueryProvider
                                                    (StateProviders)
```

`playerProvider` (`NotifierProvider<PlayerNotifier, PlayerState>`) owns a single long-lived `media_kit` `Player` instance (disposed via `ref.onDispose`). Its `playChannel(index)` / `nextChannel()` / `previousChannel()` all read **`filteredChannelsProvider`** — i.e., the player navigates the *currently filtered* list, not the full channel list. Changing the search query or selected category therefore changes what "next channel" means.

Practical consequences when adding features:
- A new piece of data derived from channels usually belongs as another `Provider` watching `channelListProvider` or `filteredChannelsProvider`, not as widget state.
- Mutations to playlist sources (`add` / `remove` / `setActive` / `updateSource`) call `StorageService` then `ref.invalidateSelf()` — this is what triggers the chain to re-fetch and re-parse.
- `PlaylistSource.effectiveUrl` synthesizes the Xtream Codes M3U URL (`{base}/get.php?username=…&password=…&type=m3u_plus&output=ts`) — never use `source.url` directly when fetching; always use `effectiveUrl`.

### M3U parsing (`lib/services/m3u_parser.dart`)

Single-pass line walker. For each `#EXTINF:` line it extracts `key="value"` attributes (`tvg-name`, `tvg-logo`, `tvg-id`, `tvg-language`, `group-title`), the duration after `#EXTINF:`, the title from the text after the **last** comma on the line, then advances to the next non-empty / non-`#` line for the URL. Entries without a URL are silently dropped. `tvg-language` and `group-title` flow into `categoriesProvider` and are how the sidebar is built.

### Playback (`lib/screens/player/player_screen.dart`)

`VideoController` is created in `initState` from `playerProvider.notifier.player` and `playChannel(initialIndex)` is invoked via `Future.microtask`. The screen owns transient UI state (overlay visibility + 3-second auto-hide timer, mouse-move reveal). Keyboard handling: `Esc` exits fullscreen or returns to `/channels`, `Space` toggles play/pause, `F` toggles fullscreen (uses `windowManager.setFullScreen` — desktop-only API; if reused on Android, guard with `Platform.isAndroid`). On dispose the screen calls `notifier.stop()`, but the `Player` itself stays alive (it's owned by the provider).

### Persistence (`lib/services/storage_service.dart`)

Single Hive box `'playlists'` of `PlaylistSource`. `setActive` enforces the single-active invariant by clearing `isActive` on every other entry before setting the new one — preserve this when adding similar mutations.

## Conventions

- Screens are `ConsumerWidget` / `ConsumerStatefulWidget`; prefer `ref.watch` in `build`, `ref.read` in callbacks.
- Navigation uses `context.go(...)` (replace), not `context.push` — back navigation is explicit via app-bar buttons / Esc handling.
- Lints: `package:flutter_lints/flutter.yaml` defaults; no project-specific overrides in `analysis_options.yaml`.
- Tests: only a placeholder exists (`test/widget_test.dart`). There is no established widget-test pattern yet.
