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
do this is via the following tools:

- [`ffmpeg`](https://ffmpeg.org/).
- [`gifsicle`](https://www.lcdf.org/gifsicle/)

Given an input `mp4` recording of some functionality, generate a gif as follows:

Set file variables:

```sh
export INPUT_MP4=input.mp4
export OUTPUT_GIF=output.gif
```

Convert mp4 to gif:

```sh
ffmpeg \
  -ss 0 \
  -i $INPUT_MP4 \
  -vf "fps=10,scale=1080:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 -f gif - | gifsicle --optimize=3 --delay=5 > $OUTPUT_GIF
```
