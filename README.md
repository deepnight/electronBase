# Electron app base for Haxe

## About

**This project is the minimal structure to easily build an [Electron](https://www.electronjs.org/) based app using [Haxe](https://haxe.org) language.**

## Features
 - [Haxe](https://haxe.org) + [Heaps](https://heaps.io) engine to render 2D/3D in a WebGL canvas
 - jQuery for all DOM manipulations (you can use something else if you prefer)
 - Electron auto-updater (using Git releases)

## Requirements

You will need:
 - [Haxe](https://haxe.org) compiler,
 - [NPM](https://www.npmjs.com/) to install dependencies,
 - My libs `deepnightLibs` for Haxe.

## Installation

### Getting Haxe and my libs:

Please refer to this tutorial to install Haxe: [Quick guide to install Haxe](https://deepnight.net/tutorial/a-quick-guide-to-installing-haxe/).

### Install "deepnightLibs"

Run the following command to install my `deepnightLibs`:
```
haxelib git deepnightLibs https://github.com/deepnight/deepnightLibs.git
```

### Install Electron and dependencies

After retrieving the source code, open a command line **in the root of the repo** and run:

```
npm i
```

## Repo structure
- `src/electron.main`: Haxe source code for the Electron Main (ie. very first JS file to be ran on startup).
- `src/electron.renderer`: Haxe source code for the Electron Renderer (ie. the actual app browser window).
- `src/bindinds`: various extern bindings for Haxe (jQuery, electron auto-updater etc).
- `electron`: Electron related files (ie. application and redistributable assets)
- `res`: Heaps (webGL) resources, if any.