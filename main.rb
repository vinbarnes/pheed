#!/usr/bin/env ruby

asset_path = ""
asset_url = ""
asset_length = ""
asset_duration = ""
asset_mimetype = ""
asset_title = ""
asset_guid = "" # pheed02

# Appends <item> element to <channel> parent that contains all the
# relevant episode details.
#
# For example, here is a detail element:
#
#     <enclosure
#       url=#{asset_path}"https://github.com/vinbarnes/pheed/raw/main/assets/marionawfal_space_09DEC2023.mp3"#       type="audio/mpeg"
#       length="82347023"
#     />
#
def append_item_to_feed(opts={}, feed="./feed.xml")
  require "nokogiri"

  feed = Nokogiri::XML(open(feed))
  parent = feed.search("rss channel")

  item_template = Nokogiri::XML::DocumentFragment.parse <<~EOXML
    <item>
      <author>Allen Nostromo</author>
      <itunes:author>Allen Nostromo</itunes:author>
      <title>#{opts["title"]}</title>
      <pubDate>#{Time.now.utc}</pubDate>
      <enclosure url="#{opts["path"]}" type="#{opts["mimetype"]}" length="#{opts["length"]}"/>
      <itunes:duration>#{opts["duration"]}</itunes:duration>
      <guid isPermaLink="false">#{opts["guid"]}</guid>
      <itunes:explicit>no</itunes:explicit>
      <description>
        https://github.com/vinbarnes/pheed

        #{opts["description"]}
        #{opts["source"]}
        </description>
    </item>
  EOXML

  new_item = feed.create_element("item")
  # parent <<
end
