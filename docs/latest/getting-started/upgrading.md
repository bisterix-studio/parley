---
description: |
  Upgrading
---

This guide covers how to upgrade Parley. To use this guide properly, navigate to
the version from which you are upgrading and work your way upwards. Unless
stated otherwise, it is mandatory to follow every upgrade step from the version
your are on.

## Prerequisites

- Parley is [installed](./installation.md) and running in your Godot Editor.

## Version `1.x.x` to `2.x.x`

1. Download and [install](./installation.md) Parley `v2.x.x`.
2. Replace of extensions of `ParleyFactInterface` with `ParleyFactInterface`.
3. Within each Fact definition, add a method matching the `evaluate`
   `ParleyFactInterface` method contract.
4. Within each Fact definition, remove the `execute` method as this is no longer
   used.
5. Within each Action definition, add a method matching the `run`
   `ParleyActionInterface` method contract.
6. Within each Action definition, remove the `execute` method as this is no
   longer used.
7. Replace `Parley.start_dialogue` with `Parley.run_dialogue` and ensure the
   `ctx` parameter is of type: `ParleyContext`.
8. Replace any interface of `ParleyDialogueSequenceAst.process_next` with
   `ParleyDialogueSequenceAst.next` and adjust the interface as appropriate.
