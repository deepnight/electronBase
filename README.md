# Electron app base for Haxe

## About

**This project is the minimal structure to easily build an [Electron](https://www.electronjs.org/) based app using [Haxe](https://haxe.org) language.**

## Features
 - [Haxe](https://haxe.org) + [Heaps](https://heaps.io) engine to render 2D/3D in a WebGL canvas
 - jQuery for all DOM manipulations (you can use something else if you prefer)
 - Electron auto-updater (using Git releases)

# Installing

## Requirements

You will need:
 - [Haxe](https://haxe.org) compiler,
 - [NPM](https://www.npmjs.com/) to install dependencies,
 - My libs `deepnightLibs` for Haxe (see below),
 - [VScode](https://code.visualstudio.com/) is recommended.


## Installing Haxe

Please refer to this tutorial to install Haxe: [Quick guide to install Haxe](https://deepnight.net/tutorial/a-quick-guide-to-installing-haxe/).

## Getting "deepnightLibs"

Run the following command to install my `deepnightLibs`:
```
haxelib git deepnightLibs https://github.com/deepnight/deepnightLibs.git
```

## Getting the source code

### Method 1: fork

Nothing special here, you probably know the drill.

### Method 2: using GitHub template

Just go to the [ElectronBase repository](https://github.com/deepnight/electronBase) on GitHub and click on the "**Use this template**" button.

Learn more about [GitHub templates here](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template).

### Method 3: adding an upstream remote

This method is quite similar to a fork:

 1. Make a new empty repo somewhere. It *must* be **strictly empty**: no LICENSE, no README, nothing.
 2. Clone it on your system
 3. Run:
```
git remote add electronBase https://github.com/deepnight/electronBase.git
git pull electronBase master
git push origin master
```

## Installing Electron and dependencies

After retrieving the source code, open a command line **in the root of the repo** and run:

```
npm i
```

# Usage

## Repo structure
- `src/electron.main/`: Haxe source code for the Electron Main (ie. very first JS file to be ran on startup).
- `src/electron.renderer/`: Haxe source code for the Electron Renderer (ie. the actual app browser window).
- `src/bindinds/`: various extern bindings for Haxe (jQuery, electron auto-updater etc).
- `electron/`: Electron related files (ie. application and redistributable assets)
- `res/`: Heaps (webGL) resources, if any.

## Compiling

To build the Electron main JS:
```
haxe main.debug.hxml
```

To build the Electron renderer JS:
```
haxe renderer.debug.hxml
```

Alternatively, you can build non-debug files using:
```
haxe main.hxml
haxe renderer.hxml
```
Or:
```
npm run compile
```

## Running

To run the compiled app:
```
npm start
```
**NOTE:** for some obscure reason, this last command might not work. You can still run the app by either:
 - using **VScode**, and executing `Start debugging` command.
 - run `npm run pack-test` to quickly create an unpacked redistributable, then execute the `.exe` file in the `/electron/redist/win-unpacked` folder.

## Creating redistributables

**Windows**:
```
npm run pack-win
```

**macOS** (requires an actual OSX environment):
```
npm run pack-macos
```

**Linux**:
```
npm run pack-linux-x86
```

