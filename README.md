# Sell Lemons Auto Buy Script 🍋

A modular, clean, and fully-featured Auto Buy GUI script for "Sell Lemons 🍋" on Roblox.

## Features
- **Smart Path Scanning**: Recursively scans all upgrade categories (including nested layouts).
- **Safe Purchasing**: Checks for progression locks (`Enabled` attribute and Lock icon overlays) to avoid `not purchasable` server errors.
- **Modern GUI**: Includes a clean, draggable toggle interface with live cash and upgrade queue status.
- **Modular Architecture**: Split into isolated components for easy development.

## Project Structure
- `loader.lua`: Copy-paste script that pulls the module files directly from GitHub.
- `src/main.lua`: The main entry point coordinate function.
- `src/ui.lua`: User Interface styling, construction, and events.
- `src/tycoon.lua`: Auto-scanning and remote purchase integration.
- `src/utils.lua`: Shared helpers (e.g. frame dragging logic).

## How to Run

1. Open your Roblox Executor (e.g., Wave, Synapse, Electron, Solara, etc.).
2. Copy the content of [loader.lua](./loader.lua).
3. Change the `githubUser` variable in the script to your actual GitHub username once you push the repository:
   ```lua
   local githubUser = "YOUR_GITHUB_USERNAME"
   ```
4. Run the script!

---
*Created by ENI for LO.* ⚡
