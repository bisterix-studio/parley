---
description: |
  Installation
---

You can download Parley directly or install it from the Asset Lib in the Godot
Editor.

## Prerequisites

- [Godot 4.4+](https://godotengine.org/) is installed.

## Instructions

### Option 1: Installing from the Godot Asset Lib within the Editor

1. Select the AssetLib button at the top of the Godot Editor.
2. Search for `Parley` in the search box.
3. Select the Parley plugin.
4. Click `Install`. This will kick off the download.
5. Complete the first time installation by following the
   [first-time installation instructions](#first-time-installation) below.

### Option 2: Download and install

<!-- TODO: correct the link -->

1. Download the compressed zip file from the
   [Parley releases page on GitHub](https://github.com/bisterix-studio/parley/releases)
   or from the
   [Godot Asset Library](https://godotengine.org/asset-library/asset/TODO).
2. Extract the compressed zip file and place the `parley` directory into your
   `addons` directory in your project.
3. Complete the first-time installation by following the
   [first-time installation instructions](#first-time-installation) below.

### First-time installation

![installation](../../../www/static/docs/installation/installation.gif)

> [tip]: If you'd like to access and follow along using the supporting video
> instead, please find the original mp4
> [here](https://github.com/bisterix-studio/parley/blob/main/www/static/docs/installation/installation.mp4).

1. Enable the Parley plugin for your project by navigating to: `Project` ->
   `Project Settings` -> `Plugins` and ticking `Enabled`.

> [warn]: When you install Parley for the first time, the following Stores will
> need to be set up, otherwise you will receive some warnings in the Editor:
>
> - Action Store
> - Fact Store
> - Character Store
>
> You don't need to add items to them at this point, just the presence of the
> stores is sufficient.
>
> To resolve these warnings, follow the steps below.

2. Navigate to the `ParleyStores` dock and select the `Character` tab.
3. Click the `Create and register new Store` button to open the Character Store
   registration modal.
4. Give the Character Store an ID. In our example, we call this: `main`
5. Set the path where the Character Store resource will be saved. In our
   example, we set this to: `res://characters/character_store.tres`
6. Click: `Register` to save and register the Character Store. You should see
   the warning button disappear in the `ParleyStores` dock.
7. The Character Store is now set up and ready to be used. You can find out more
   about the Character Store [here](../stores/character-store.md).
8. Repeat the above steps for the Fact Store via the `Fact` tab in the
   `ParleyStores` dock. You can find out more about the Fact Store
   [here](../stores/fact-store.md).
9. Repeat the above steps for the Action Store via the `Action` tab in the
   `ParleyStores` dock. You can find out more about the Action Store
   [here](../stores/action-store.md).
10. Now everything is set up, you can start
    [creating Dialogue Sequences](./create-dialogue-sequence.md)!
