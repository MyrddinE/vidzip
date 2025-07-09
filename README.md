# vidzip

This file searches a video for the signature of an embedded / appended ZIP, and optionally extracts it.

## Installation

None. Add it to your path if you like, or put it in the same directory as your video files.

## Usage

    `vidzip [--extract] video.mp4`

If you leave out the extract option, it will simply inform you whether a possible zipfile was found.
If the extract option is included, it will extract the zip from the video (if found).

## Development

This was vibe-coded with the Gemini 2.5 Pro model, using Gemini-CLI, in Crystal 1.11.2, using about $2 worth of token data.

## Contributing

1. Fork it (<https://github.com/MyrddinE/vidzip/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Myrddin Emrys](https://github.com/MyrddinE) - Principle Viber
