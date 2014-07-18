require "uri"
require "open-uri"
require "progressbar"
require "multi_json"
require "tmpdir"
require "streamio-ffmpeg"

# get from http://api.justin.tv/api/broadcast/by_archive/<broadcast_id>.json

# returns array of objects, each having a video_file_url key

BASE_JSON_URL = "http://api.justin.tv/api/broadcast/by_archive/"
OUTPUT_DIR = "output"

broadcast_id = ARGV[0]
title = ARGV[1]

unless broadcast_id && broadcast_id =~ /\d+/
  puts "Usage: bundle exec archive <broadcast_id> [<title>]"
  exit
end

broadcast_id = "541906699"

files = MultiJson.load(open(URI.join(BASE_JSON_URL, broadcast_id + ".json")))

Dir.mktmpdir do |dir|

end

progress_bar = nil

File.open(File.join(Dir.pwd, "part_0.flv"), "w") do |f|
  f.write(open(files[0]["video_file_url"], {
    :content_length_proc => lambda do |t|
      if t && 0 < t
        progress_bar = ProgressBar.new("...", t)
        progress_bar.file_transfer_mode
      end
    end,

    :progress_proc => lambda do |s|
      progress_bar.set s if progress_bar
    end
  }).read)
end
