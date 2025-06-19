# Contributing

## Pre-requisites

This repo using git hooks to ensure that the code is committed in a good state.
To install the hooks, run the following command:

```bash
git config core.hooksPath .githooks
```

Ensure the following are installed:

- [Godot](https://godotengine.org/)

## Documentation

Documentation is a vital part of Parley and should always be included for any
change in functionality.

### Via gifs

We are big fans of using gifs to demonstrate functionality. The easiest way to
do this is via [`ffmpeg`](https://ffmpeg.org/). Given an input `mp4` recording
of some functionality, generate a gif as follows:

```sh
ffmpeg \
  -ss 0 \
  -i input.mp4 \
  -vf "fps=10,scale=1080:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 \
  output.gif
```
