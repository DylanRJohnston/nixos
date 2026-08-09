# Agent Notes

## Project Overview

A personal Nix configuration using `flake.nix` with [den](https://github.com/dylanrjohnston/den) as the underlying framework and `import-tree` for module discovery.

## Module Auto-Discovery

All `.nix` files under `./modules` and `./hosts` are automatically imported via `import-tree`. **Never edit `flake.nix` to add imports** — just place a new `.nix` file in the right directory.

## Config Classes

Each aspect can define config for different targets using these keys:

| Key            | Applies to                        |
|----------------|-----------------------------------|
| `.nixos`       | NixOS systems only                |
| `.darwin`      | macOS (nix-darwin) systems only   |
| `.os`          | Both NixOS and macOS              |
| `.homeManager` | home-manager (all platforms)      |
| `.user`        | User-level config                 |

## The `arc` Aspect System

This codebase is organised around **aspects** — named, composable units of configuration. Understanding this is essential for any module work.

- Aspects live at `arc.<name>` (e.g. `arc.base`, `arc.gaming`, `arc.interactive`)
- Hosts opt into aspects via their `aspects = [ ... ]` list in `hosts/<name>/<name>.nix`
- Named sub-aspects (`arc.<aspect>._.<name>`) exist for debuggability — they are **not** automatically included; their parent must explicitly include them

> For full details on the aspect system, named sub-aspects, includes, and worked examples, see [`agents/aspect-system.md`](agents/aspect-system.md).
> Read this before adding, restructuring, or debugging any module.

## Host Files

Hosts live under `hosts/<name>/<name>.nix` (or `hosts/<name>.nix` for simple cases). They declare the host's system, users, and which aspects apply.
