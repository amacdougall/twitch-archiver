require "uri"
require "open-uri"
require "progressbar"
require "multi_json"
require "tempfile"
require "streamio-ffmpeg"

# get from http://api.justin.tv/api/broadcast/by_archive/<broadcast_id>.json

BASE_JSON_URL = "http://api.justin.tv/api/broadcast/by_archive/"

broadcast_id, title = ARGV

unless broadcast_id && broadcast_id =~ /\d+/ && title
  puts "Usage: bundle exec archive <broadcast_id> <title>"
  exit
end

file_json = MultiJson.load(open(URI.join(BASE_JSON_URL, broadcast_id + ".json")));

output_dir = title

unless Dir.exists? output_dir
  Dir.mkdir output_dir
end

unless Dir["#{output_dir}/*"].empty?
  FileUtils.rm_rf(Dir.glob("dir/to/remove/*")) # remove directory contents
end

total_files = file_json.length

file_json.each_with_index do |file_data, index|
  tempfile = Tempfile.new(["archive_download", ".flv"])

  begin
    progress_bar = nil

    # download and write to tempfile
    puts "Downloading #{file_data["title"]} part #{index}/#{total_files}..."
    tempfile.write(open(file_data["transcode_file_urls"]["transcode_480p"], {
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

    # transcode to MP4
    puts "Transcoding #{file_data["title"]} part #{index}/#{total_files}..."
    movie = FFMPEG::Movie.new(tempfile.path)
    progress_bar = ProgressBar.new("...", 1.0)

    # pad the index in the filename to the max digits; i.e. if 14 files, name
    # them "00", "01", ...
    padded_index = index.to_s.rjust(total_files.to_s.length, "0")

    movie.transcode(File.join(output_dir, "part_#{padded_index}.mp4")) do |progress|
      # clamp to max of 1.0; streamio-ffmpeg sometimes issues 1.000001 progress.
      progress_bar.set([progress, 1.0].min)
    end
  ensure
    tempfile.close
    tempfile.unlink
  end
end

puts "Complete: saved to folder #{title}!"
