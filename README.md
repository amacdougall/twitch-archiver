twitch-archiver
===============

**Update:** In shutting down the justin.tv API, Twitch has also knocked this script out of commission.

Intended mainly for my personal use, so I can watch archived streams on my phone; I'd hate to see Twitch put the brakes on this kind of sideband stuff. Requires ffmpeg; confirmed working with ffmpeg 2.2.

Twitch saves the broadcasts as a series of thirty-minute FLV files; this script writes them out in the same thirty-minute chunks.

## Usage

`bundle exec ruby archive.rb <broadcast_id> <output_dir>`

`broadcast_id` is the final numeric part of a past broadcast URL such as `http://www.twitch.tv/leveluplive/b/546149859`; `output_dir` is the directory to which the output files will be saved.
