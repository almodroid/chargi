# <img src="AppIcon.appiconset/icon-128.png" alt="Chargi Icon" width="32" height="32"> Chargi

Chargi is a minimal, focused macOS menu bar app that shows charging status and time remaining, with a floating bubble and a widget. It’s lightweight, private, and stays out of your way.

## Features

- Menu bar battery time or icon with charging pulse
- Floating bubble window with status and quick hide/quit
- Home Screen widget for time remaining
- Cache tools with auto-clean rules
- Modern app icon with rotate, clock, and bolt

## Install

1. Build the app bundle and DMG:
   - `zsh scripts/package_app.sh`
2. Open the DMG and drag `Chargi.app` to `Applications`.

## Usage

- Launch Chargi; it runs as a background agent (`LSUIElement`) without a Dock icon.
- Use the menu bar icon:
  - Toggle `Floating Bubble`
  - Toggle `Widget Content`
  - Toggle `Show Time In Menu Bar`
  - `Quit`
- Right‑click the floating bubble for quick `Hide Bubble` and `Quit`.

## Building

- Requires macOS with Xcode command line tools.
- Build script compiles a standalone AppKit binary and creates a `.app` bundle and `.dmg`:
  - `scripts/package_app.sh`
  - Output: `dist/Chargi.app`, `dist/Chargi.dmg`

## Icons

- If `Resources/AppIcon.icns` is missing, the script generates a modern icon from vectors and bundles it.
- Runtime also sets a fallback drawn icon.

## Privacy

- Chargi runs locally and does not send data anywhere.

## Uninstall

- Quit the app, then remove `Applications/Chargi.app`.
