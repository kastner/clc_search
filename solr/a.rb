require 'rubygems'
require 'open-uri'
require 'json'

base_url = "https://api.colourlovers.com/1.0/colors?numResults=100&sortBy=ASC&orderCol=rank&apiKey=&format=json&page=%s"
10000.times do |page|
  #puts "gonna get #{base_url % (page + 1)}"
  data = %x{curl -s "#{base_url % (page + 1)}"}

  color_data = JSON.parse(data)
  colors = []

  color_data["colors"].each do |color|
    new_c = {}
    new_c.merge! color["rgb"]
    new_c.merge! color["hsv"]
    ["imageUrl", "name", "userName", "title", "url", "hex", "rank", "id", "userID", "dateCreated", "numScores"].each do |field|
      new_c[field] = color[field] ||= ""
    end
    #new_c.keys.each do |key|
    #  puts %Q{<field name="#{key}" type="string" indexed="true" stored="true" required="true" />}
    #end
    colors << new_c
  end

  path = "/tmp/pop-colors-#{page}.json"
  File.open(path, "w") do |f|
    f.puts colors.to_json
  end
  puts %x{curl 'http://localhost:8983/solr/update/json?commit=true' --data-binary @#{path} -H 'Content-type:application/json'}
  sleep 1
end
