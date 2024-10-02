#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'
require 'rss'
require 'time'
require 'erb'
require 'random/formatter'

def download_audio(url)
  command = "yt-dlp -x --audio-format mp3 --audio-quality 8 --restrict-filenames --trim-filenames 65 -o 'assets/%(title).150B-[%(id)s].%(ext)s' --cookies-from-browser safari #{url}"
  output = `#{command} 2>&1`

  # Extract the file path from the output
  file_path = output.match(/\[ExtractAudio\] Destination: (.+\.mp3)/)&.[](1)

  if file_path.nil? || !File.exist?(file_path)
    puts "yt-dlp output:"
    puts output
    raise "Failed to download audio file or extract file path"
  end

  file_path
end

def get_video_metadata(url)
  # TODO works for YouTube not Twitter
  doc = Nokogiri::HTML(URI.open(url))
  {
    title: doc.at_css('meta[property="og:title"]')&.[]('content'),
    description: doc.at_css('meta[property="og:description"]')&.[]('content'),
    publish_date: Time.parse(doc.at_css('meta[itemprop="datePublished"]')&.[]('content') || Time.now.to_s)
  }
end

def get_audio_duration(file_path)
  `ffprobe -i "#{file_path}" -show_entries format=duration -sexagesimal -v quiet -of csv="p=0"`.strip
end

def update_feed(file_path, metadata, duration)
  # Load existing items from feed.xml if it exists
  existing_items = []
  if File.exist?('feed.xml')
    existing_content = File.read('feed.xml')
    existing_items = existing_content.scan(/<item>.*?<\/item>/m)
  end

  # Prepare the new item
  new_item = <<-EOT.strip
  <item>
      <author>Allen Nostromo</author>
      <itunes:author>Allen Nostromo</itunes:author>
      <title>#{ERB::Util.html_escape(metadata[:title])}</title>
      <pubDate>#{metadata[:publish_date].rfc2822}</pubDate>
      <enclosure url="https://github.com/vinbarnes/pheed/raw/main/assets/#{ERB::Util.url_encode(File.basename(file_path))}" type="audio/mpeg" length="#{File.size(file_path)}" />
      <itunes:duration>#{duration}</itunes:duration>
      <guid isPermaLink="false">#{Random.uuid}</guid>
      <itunes:explicit>no</itunes:explicit>
      <description>#{ERB::Util.html_escape(metadata[:description])}</description>
    </item>
  EOT

  # Construct the full RSS feed
  rss_content = <<-EOT
<?xml version="1.0" encoding="UTF-8" ?>
<rss xmlns:googleplay="http://www.google.com/schemas/play-podcasts/1.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:rawvoice="http://www.rawvoice.com/rawvoiceRssModule/" xmlns:content="http://purl.org/rss/1.0/modules/content/" version="2.0">
  <channel>
    <title>Pheed Me</title>
    <googleplay:author>Allen Nostromo</googleplay:author>
    <rawvoice:rating>TV-R</rawvoice:rating>
    <rawvoice:location>San Francisco, California</rawvoice:location>
    <rawvoice:frequency>Weekly</rawvoice:frequency>
    <author>Allen Nostromo</author>
    <itunes:author>Allen Nostromo</itunes:author>
    <itunes:email>kevin@devcostar.com</itunes:email>
    <itunes:category text="Technorati" />
    <image>
      <url>https://raw.githubusercontent.com/vinbarnes/pheed/main/assets/grandmapo.webp</url>
      <title>Pheed Me</title>
      <link>https://vinbarnes/pheed</link>
    </image>
    <itunes:owner>
      <itunes:name>Kevin Barnes</itunes:name>
      <itunes:email>kevin@devcostar.com</itunes:email>
    </itunes:owner>
    <itunes:keywords>web,crypto</itunes:keywords>
    <copyright>Dev Co-star #{Time.now.year}</copyright>
    <description>Exploring indefatigably</description>
    <googleplay:image href="https://raw.githubusercontent.com/vinbarnes/pheed/main/assets/grandmapo.webp" />
    <language>en-us</language>
    <itunes:explicit>no</itunes:explicit>
    <pubDate>#{Time.now.rfc2822}</pubDate>
    <link>https://raw.githubusercontent.com/vinbarnes/pheed/main/feed.xml</link>
    <itunes:image href="https://raw.githubusercontent.com/vinbarnes/pheed/main/assets/grandmapo.webp" />
    #{existing_items.join("\n    ")}
    #{new_item}
  </channel>
</rss>
  EOT

  File.write('feed.xml', rss_content)
end

# Main execution
if $PROGRAM_NAME == __FILE__

  if ARGV.length != 1
    puts "Usage: ruby add_asset.rb <url>"
    exit 1
  end

  url = ARGV[0]
  audio_file = download_audio(url)
  metadata = get_video_metadata(url)
  duration = get_audio_duration(audio_file)
  update_feed(audio_file, metadata, duration)

  puts "Audio downloaded and feed updated successfully"
  exit 0
end
