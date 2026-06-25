# Mineradio Fork — AI Agent Guide

## 1. Purpose

This file defines the working rules for any AI coding agent used in this repository.

The rules are tool-agnostic. Do not assume the agent is Codex, Claude Code, Cursor, Copilot, or any other specific product.

Project information:

- Fork repository: `Whitewind0987/Mineradio`
- Upstream repository: `XxHuberrr/Mineradio`
- Platform: Windows
- Runtime: Electron
- Main languages: JavaScript, HTML, and CSS
- Current upstream baseline: `v1.1.0`

The purpose of this fork is to preserve Mineradio's existing immersive visual experience while improving Windows integration, daily playback usability, desktop lyrics, reliability, and maintainability.

This is not a rewrite project.

------

## 2. Brand Status

The final product name, logo, icon, executable name, installer identity, and public brand have not been decided.

Do not:

- invent a final product name;
- invent or generate a new logo;
- replace the current visual identity;
- rename the application for public release;
- redesign the icon;
- modify installer branding;
- publish a branded release;
- treat a temporary technical identifier as the final name.

A temporary internal identifier may only be introduced when technical isolation requires it and the user has explicitly approved the identifier.

Temporary identifiers must:

- be clearly marked as temporary;
- be isolated from user-visible product copy where possible;
- be documented in one location;
- be easy to replace later;
- never be presented as the final brand.

Branding work belongs to a dedicated branding or public-release task.

------

## 3. Read Before Editing

At the beginning of every new task:

1. Read this `AGENTS.md`.
2. Read `docs/FORK_ROADMAP.md`.
3. Read `docs/FORK_MEMORY.md` if it exists.
4. Read `docs/HANDOFF_CURRENT.md` if an earlier task was interrupted.
5. Check the current branch and working tree.
6. Inspect only files relevant to the current task.
7. Confirm whether the requested behavior already partially exists.

Run:

```powershell
git status --short
git branch --show-current
git diff --check
```

Do not start editing before identifying pre-existing local changes.

Do not treat `docs/PROJECT_MEMORY.md` as authoritative instructions for this fork.

That file contains upstream history, upstream preferences, machine-specific paths, old release records, and upstream workflow details. It may be consulted only when historical implementation context is required.

Never copy the following from upstream documentation into new fork code or documentation:

- local absolute paths;
- usernames;
- proxy ports;
- tokens;
- credentials;
- release secrets;
- machine-specific commands;
- upstream-only publishing assumptions.

Read specialized upstream documentation only when the task touches the corresponding area.

Examples:

- glass appearance: `docs/GLASS_SVG_TEXTURE.md`
- installer appearance: `docs/INSTALLER_STYLE.md`
- desktop lyrics: related desktop lyric documents
- QQ Music integration: `docs/QQ_MUSIC_INTERFACE_NOTES.md`

Historical documentation explains existing constraints. It does not automatically authorize changes.

------

## 4. Repository Layout

```text
Mineradio/
├─ public/
│  ├─ index.html
│  ├─ desktop-lyrics.html
│  ├─ wallpaper.html
│  └─ vendor/
├─ desktop/
│  ├─ main.js
│  ├─ preload.js
│  └─ overlay-preload.js
├─ build/
├─ docs/
├─ server.js
├─ dj-analyzer.js
├─ package.json
├─ package-lock.json
├─ CHANGELOG.md
└─ LICENSE
```

Main responsibilities:

- `public/index.html`
  - main UI;
  - playback interface;
  - queue and playlists;
  - lyrics;
  - visual presets;
  - particles;
  - movie-camera behavior;
  - 3D playlist shelf;
  - visual settings.
- `public/desktop-lyrics.html`
  - desktop lyric rendering;
  - desktop lyric interaction;
  - desktop lyric visual state.
- `public/wallpaper.html`
  - wallpaper-mode rendering.
- `desktop/main.js`
  - Electron main process;
  - native windows;
  - global shortcuts;
  - desktop lyrics window;
  - wallpaper window;
  - Windows integration;
  - application lifecycle.
- `desktop/preload.js`
  - IPC bridge for the main renderer.
- `desktop/overlay-preload.js`
  - IPC bridge for overlay windows.
- `server.js`
  - local HTTP server;
  - music platform APIs;
  - audio source resolution;
  - login data;
  - updates;
  - local caches.
- `dj-analyzer.js`
  - audio and rhythm analysis.

Important facts:

- `public/index.html` is very large and high risk.
- Playback, UI, lyrics, visual effects, and persistence are heavily coupled.
- There is no complete automated test suite.
- Existing behavior must be located before adding new behavior.
- Existing visual quality is part of the product and must not be casually replaced.

------

## 5. Source-of-Truth Documents

Use the documents for these purposes:

### `AGENTS.md`

Stable rules that apply to all tasks.

### `docs/FORK_ROADMAP.md`

Planned stages and unimplemented work.

### `docs/FORK_MEMORY.md`

Completed, manually verified, and accepted fork behavior.

### `docs/HANDOFF_CURRENT.md`

Temporary handoff information for an unfinished task.

### `docs/PROJECT_MEMORY.md`

Upstream historical reference only.

Do not mix planned work into `FORK_MEMORY.md`.

Do not treat historical upstream decisions as permanent fork requirements unless the user confirms them.

------

## 6. Core Working Principles

### 6.1 Inspect before editing

Before changing code:

- locate the existing UI element;
- locate its selectors;
- locate the current state variable or state object;
- locate all event handlers involved;
- locate persistence keys;
- locate restore logic;
- locate IPC channels;
- locate preload APIs;
- locate cleanup behavior;
- locate all references before renaming or deleting;
- trace both the write path and the read path;
- check full-screen, background, desktop lyric, and restart behavior where relevant.

Do not guess:

- function names;
- selector names;
- storage keys;
- IPC channel names;
- state shapes;
- data formats;
- file locations;
- event flow.

For high-risk tasks, summarize the existing control flow before editing.

### 6.2 Keep patches small

For every task:

- change only what the stated goal requires;
- do not perform unrelated cleanup;
- do not reformat unrelated code;
- do not rename unrelated variables;
- do not silently fix extra problems;
- do not add speculative features;
- do not create a second implementation beside an existing one;
- prefer extending existing functions and state;
- keep the diff reviewable.

When a task appears to require changes to more than four source files, stop and explain why before expanding the scope.

Documentation and tests do not count toward this limit.

### 6.3 One task per branch

Do not combine unrelated work.

Examples of work that must remain separate:

- tray support and lyric redesign;
- login fixes and update changes;
- desktop lyrics and source matching;
- compact mode and code extraction;
- Cookie encryption and UI redesign;
- dependency upgrades and feature work;
- branding and playback behavior;
- security hardening and visual changes.

### 6.4 Preserve existing behavior

A new feature must not silently change unrelated behavior.

Consider:

- playback;
- pause;
- queue;
- looping;
- shuffle;
- lyrics;
- visual presets;
- desktop lyrics;
- wallpaper mode;
- account login;
- update checks;
- full screen;
- minimized mode;
- restart;
- multiple monitors.

### 6.5 Do not claim unverified success

Never report a feature as complete only because the code appears correct.

Report separately:

- checks actually run;
- checks that passed;
- checks that failed;
- checks that could not be run;
- manual testing still required;
- remaining uncertainty.

------

## 7. Protected Existing Behavior

The following areas are fragile and must not be changed unless the user explicitly names them:

- movie-camera visual system;
- particle rendering behavior;
- saved SVG glass appearance;
- Emily visual preset;
- Requiem / skull visual preset;
- 3D playlist shelf composition and movement;
- main lyric-stage appearance;
- current desktop lyric appearance and click-through behavior;
- wallpaper mode;
- playback source selection;
- login and Cookie behavior;
- update and patch system;
- installer appearance;
- saved visual profiles;
- background performance strategy.

Do not replace the existing visual language with:

- generic blur;
- ordinary glassmorphism;
- cheap gradients;
- standard dashboard cards;
- a generic music-player layout;
- excessive transparency;
- unnecessary glowing outlines;
- flat default components without matching the existing design.

Do not broadly rewrite `public/index.html`.

Do not migrate the project to React, Vue, TypeScript, Vite, or another framework unless the user explicitly starts a dedicated migration project.

------

## 8. High-Risk Files

Treat these files as high risk:

```text
public/index.html
public/desktop-lyrics.html
public/wallpaper.html
desktop/main.js
desktop/preload.js
desktop/overlay-preload.js
server.js
dj-analyzer.js
package.json
package-lock.json
build/*
```

For high-risk changes:

1. Perform read-only investigation first.
2. Identify the existing control flow.
3. Identify persistence and cleanup behavior.
4. Present a minimal implementation plan.
5. Clarify ambiguous behavior before editing.
6. Keep security work and feature work separate.
7. Keep update, login, Cookie, and installer work in dedicated tasks.
8. Avoid replacing large sections because the structure is inconvenient.

------

## 9. Context Management

Keep each task focused.

Rules:

- use targeted searches before reading large files;
- read only relevant ranges;
- do not repeatedly read large files from the beginning;
- do not dump the complete `public/index.html` into context;
- search exact selectors, functions, storage keys, and IPC channels;
- summarize discovered flow before editing;
- reuse exact existing identifiers;
- do not run multiple agents against the same files simultaneously;
- start a new session when switching to an unrelated task;
- stop editing when the scope becomes unclear.

When a session becomes too large, create or update:

```text
docs/HANDOFF_CURRENT.md
```

The handoff must contain:

- current branch;
- exact task goal;
- files inspected;
- files changed;
- existing flow discovered;
- decisions confirmed;
- checks run;
- remaining work;
- known risks;
- manual tests still required.

Do not store:

- unrelated future ideas;
- temporary guesses;
- unverified conclusions;
- copied command output without explanation;
- private data;
- credentials;
- full log dumps.

After the task is completed and recorded in `docs/FORK_MEMORY.md`, clear or replace the handoff.

------

## 10. Fork Memory Rules

Use:

```text
docs/FORK_MEMORY.md
```

to store stable and verified fork decisions.

Only record information that has been:

- implemented;
- manually verified;
- accepted by the user;
- confirmed as a long-term constraint.

Each entry should include:

- date;
- feature or decision;
- files involved;
- important state keys or IPC channels;
- verified behavior;
- known limitations;
- behavior that must not regress.

Do not record:

- unimplemented plans;
- debugging guesses;
- failed experiments;
- temporary branch details;
- copied upstream release history;
- local machine paths;
- model-specific instructions.

------

## 11. Git Rules

Default feature branch format:

```text
feature/<short-topic>
```

Examples:

```text
feature/fork-technical-isolation
feature/windows-media-session
feature/system-tray
feature/session-restore
feature/desktop-lyrics-layout
feature/lyrics-time-offset
feature/playback-diagnostics
feature/compact-mode
```

Rules:

- do not work directly on the default branch unless explicitly instructed;
- do not create a branch unless requested or required by the task;
- do not commit unless explicitly requested;
- do not push unless explicitly requested;
- do not create tags or releases unless explicitly requested;
- do not open pull requests unless explicitly requested;
- do not modify the upstream repository;
- do not rewrite Git history;
- do not discard pre-existing user changes;
- do not mix unrelated work in one commit;
- do not use destructive commands without permission.

Never use these without explicit approval:

```powershell
git reset --hard
git clean -fd
git checkout -- .
git restore .
git push --force
git push --force-with-lease
```

When the working tree is already dirty:

1. identify existing changes;
2. determine whether they belong to the current task;
3. avoid overwriting them;
4. report conflicts before editing.

Before presenting commit commands:

```powershell
git status --short
git diff --stat
git diff --check
```

------

## 12. Dependency Rules

Do not add, remove, or upgrade production dependencies unless the task requires it and the user approves.

Before proposing a dependency:

1. explain why existing Electron, Node, browser APIs, or current dependencies are insufficient;
2. explain its exact purpose;
3. check installer-size impact;
4. check for native binaries;
5. check for post-install scripts;
6. check maintenance status;
7. check license compatibility.

Prefer built-in APIs for small features.

Do not:

- perform broad dependency upgrades during feature work;
- update Electron as unrelated cleanup;
- modify the lockfile accidentally;
- install a framework for one small feature;
- replace an existing dependency without a migration plan.

------

## 13. Privacy and Secrets

Never read, print, log, upload, or commit private account data.

Protected data includes:

- `.cookie`;
- `.qq-cookie`;
- login Cookies;
- Tokens;
- QR login state;
- account identifiers;
- local music paths;
- search history;
- custom cover images;
- custom lyrics;
- listening history;
- update caches;
- visual profiles;
- diagnostic exports.

Never commit:

```text
.cookie
.qq-cookie
node_modules/
dist/
updates/
user-data/
cache/
temporary installers
local account exports
private diagnostic files
```

Do not include Cookie or Token values in:

- console logs;
- errors;
- screenshots;
- tests;
- documentation;
- diagnostic packages;
- issue reports.

Any Cookie migration must:

- preserve current login when possible;
- validate successful new storage;
- provide rollback behavior;
- avoid deleting original data before successful migration;
- be implemented in a dedicated task;
- be tested separately for each music platform.

------

## 14. Electron Security Boundaries

Preserve these defaults unless a dedicated security task explicitly changes them:

- `contextIsolation: true`;
- `nodeIntegration: false`;
- narrow preload APIs;
- explicit IPC channels;
- validated IPC arguments;
- external links opened outside the renderer;
- no unrestricted renderer filesystem access.

Do not expose generic access to:

- `fs`;
- `child_process`;
- `shell`;
- `process`;
- arbitrary IPC calls;
- arbitrary local paths;
- arbitrary command execution.

Do not add an IPC handler that accepts unrestricted commands or paths.

Do not weaken Electron security settings to simplify a feature.

Changes involving these areas require explicit risk reporting:

- login windows;
- Cookies;
- update installers;
- external URLs;
- local files;
- shell operations;
- preload APIs;
- IPC payloads;
- system startup;
- global shortcuts.

------

## 15. Coding Rules

Follow the existing coding style in the touched area.

Prefer:

- existing helper functions;
- existing state objects;
- existing persistence patterns;
- existing IPC naming conventions;
- early validation;
- explicit result objects;
- clear fallback behavior;
- small functions with one responsibility;
- comments that explain non-obvious constraints.

Avoid:

- parallel state systems;
- duplicate event listeners;
- replacing existing handlers at runtime;
- simulated button clicks when a real function exists;
- repeated timers for the same state;
- unnecessary global variables;
- silent failures in new code;
- hard-coded local paths;
- hard-coded usernames;
- hard-coded credentials;
- hidden network fallbacks;
- arbitrary delays used to hide race conditions.

When adding persisted settings:

- define a stable key;
- define defaults;
- validate restored data;
- tolerate missing values;
- tolerate corrupted values;
- tolerate older formats;
- document migration behavior;
- avoid high-frequency writes;
- do not store temporary animation state.

When adding IPC:

- use a specific channel;
- expose only the required preload method;
- validate arguments in the main process;
- return structured success or error results;
- never trust renderer input.

------

## 16. Desktop Lyrics Rules

Desktop lyrics already exist.

Any desktop lyric feature must reuse the existing:

- desktop lyric `BrowserWindow`;
- overlay preload bridge;
- lyric time source;
- lock state;
- click-through behavior;
- topmost behavior;
- desktop lyric state updates;
- window cleanup.

Do not create:

- a second desktop lyric window system;
- a second lyric parser;
- a second playback clock;
- a second audio element;
- a parallel lyric state store.

Desktop lyrics must remain:

- synchronized with the main player;
- removable when the application exits;
- safe across pause, seek, track changes, and restart;
- recoverable when a monitor is disconnected;
- unlockable after click-through is enabled.

A locked lyric window must never leave the user without a working unlock method.

Do not change the current lyric visual treatment unless the task explicitly includes a visual change.

------

## 17. Visual Change Rules

Before editing visual behavior:

1. identify the existing element and selector;
2. identify related CSS variables;
3. identify animations and transition timing;
4. identify full-screen and windowed variants;
5. identify movie-camera involvement;
6. identify saved-profile behavior;
7. identify performance behavior;
8. test more than one resolution.

Do not:

- replace SVG glass with ordinary blur;
- flatten the visual hierarchy;
- remove subtle effects merely because they are complex;
- increase transparency until text becomes unreadable;
- add excessive outlines;
- redesign unrelated UI during functional work;
- modify accepted presets as a side effect;
- duplicate controls without a clear need.

Performance work must not silently reduce normal foreground visual quality.

------

## 18. Verification Commands

Use PowerShell.

### Basic checks

```powershell
git diff --check
node --check .\server.js
node --check .\desktop\main.js
node --check .\desktop\preload.js
node --check .\desktop\overlay-preload.js
node --check .\dj-analyzer.js
```

Only run checks for relevant files that exist.

### Development run

```powershell
npm start
```

After testing:

- close Electron;
- close login windows;
- close spawned local servers;
- verify no unnecessary Node or Electron processes remain.

### Unpacked Windows build

Use for changes involving:

- Electron main process;
- preload;
- native windows;
- tray;
- shortcuts;
- media controls;
- desktop lyrics;
- system startup;
- icons;
- packaging behavior.

```powershell
npm run build:win:dir
```

### Full installer build

Run only for an explicit installer or release task:

```powershell
npm run build:win
```

Do not repeatedly build the full installer during normal feature work.

------

## 19. Manual Testing Requirements

Every feature must include concrete manual test steps.

### Playback work

Test:

- play;
- pause;
- previous;
- next;
- seek;
- natural track end;
- queue changes;
- loop modes;
- shuffle;
- failed source;
- rapid track switching;
- restart.

### Window and tray work

Test:

- close;
- minimize;
- restore;
- second launch;
- full screen;
- windowed mode;
- multiple monitors;
- application exit;
- tray exit;
- restart;
- update-triggered restart.

### Lyrics work

Test:

- normal synchronized lyrics;
- word-by-word lyrics;
- line lyrics;
- no lyrics;
- instrumental tracks;
- custom lyrics;
- long lines;
- pause and resume;
- seeking;
- manual scrolling;
- track changes;
- desktop lyrics;
- lock;
- unlock;
- click-through;
- multiple monitors;
- Windows scaling;
- full-screen applications.

### Persistence work

Test:

- clean first launch;
- valid data;
- missing data;
- corrupted data;
- old-format data;
- normal restart;
- abnormal termination;
- no unexpected autoplay.

### Login and Cookie work

Test:

- clean login;
- existing login;
- expired login;
- logout;
- restart;
- failed migration;
- missing Cookie file;
- corrupted Cookie file;
- no private values in logs.

------

## 20. Definition of Done

A task is complete only when:

- requested behavior is implemented;
- acceptance criteria are met;
- unrelated behavior remains unchanged;
- syntax checks pass;
- `git diff --check` passes;
- manual testing steps are provided;
- persistence has been considered;
- restart behavior has been considered;
- failure and fallback behavior have been considered;
- no private data is exposed;
- no unrequested dependency is added;
- no unrequested rewrite is introduced;
- known limitations are reported honestly.

A task is not complete merely because:

- the application starts;
- no syntax error appears;
- one happy path works;
- the agent believes the code is correct.

------

## 21. Required Final Report

After editing, report:

### Summary

What changed and why.

### Files changed

Every modified, created, or deleted file.

### Existing flow reused

Functions, state objects, IPC channels, and persistence paths reused.

### Validation performed

Exact commands and results.

### Manual verification

Steps the user must perform.

### Risks and limitations

Remaining uncertainty.

### Git state

- current branch;
- uncommitted changes;
- pre-existing changes that remain.

Do not include commit, push, merge, or release commands unless requested.

------

## 22. Stop Conditions

Stop editing and ask for clarification when:

- the requirement has multiple plausible meanings;
- protected visual behavior would change;
- more than four source files appear necessary;
- a large section of `public/index.html` would need replacement;
- login, Cookie, update, or installer changes become unexpectedly necessary;
- an external service contract is unclear;
- user data may be migrated or deleted;
- local changes conflict with the task;
- the behavior cannot be verified safely;
- an existing implementation may already handle the feature;
- the task expands into unrelated work;
- a security boundary would need to be weakened;
- a final name, Logo, or public brand decision is required.

When stopping:

1. explain what was inspected;
2. explain what is unclear;
3. show the relevant existing behavior;
4. ask only the minimum questions required to continue.