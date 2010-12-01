require 'rubygems'
require 'sinatra'
require 'rss'
require 'open-uri'
require 'cgi'
require './Microprinter_debug.rb' # uncomment this to print to the console instead of the printer. 
# require './Microprinter.rb' 

set :arduinoport, "/dev/cu.usbmodem24131" # or whatever yours is. 

before do
  @printer = Microprinter_debug.new(settings.arduinoport)
  # @printer = Microprinter.new(settings.arduinoport)
  @printer.set_print_mode_a
end

# def print_and_cut(text) # utility method. print line (or array of lines) then feed & cut
#   @printer.print_text(text)
#   feed_and_cut
# end

# def feed_and_cut # TODO: this should go into the microprinter library?
#   @printer.feed
#   @printer.cut
# end

def cleanHTML(text)
  # nb could use htmlentities library to unencode HTML entities, but how to deal with non-ascii characters? Need to turn unicode chars to plain text somehow 
  newtext = text
  newtext.gsub! "&\#8211;", "-" #replace em-dash
  newtext.gsub! "&\#8216;", "'" # replace curly quotes
  newtext.gsub! "&\#8217;", "'"
  newtext.gsub! "&\#8230;", "..."
  return newtext
end 

get '/print/cut' do
  @printer.cut
  "cut"
end 

get '/print/weather' do
  # print content from http://www.bbc.co.uk/weather/ukweather/south/cloud.shtml?summary=show02
  @weatherurl = "http://boilerpipe-web.appspot.com/extract?extractor=LargestContentExtractor&output=text&url=http%3A%2F%2Fwww.bbc.co.uk%2Fweather%2Fukweather%2Fsouth%2Fcloud.shtml%3Fsummary%3Dshow02"
  weather_content = ""
  open(@weatherurl) do |f|
    weather_content = f.read
  end
  print_and_cut weather_content.split("\n")
  "Weather printed"
end

get '/print' do
  pass unless params[:text] # use this rule if 'text' param exists
  @text = params[:text]
  print_and_cut [@text, "", request.url]
  "Text: #{@text}"
end

get '/print' do
  pass unless params[:url] # use this rule if 'url' param exists
  @url = params[:url]
  #TODO: do some processing...
  "Url: #{@url}"
end

get '/print' do
  pass unless params[:feed] # use this rule if 'rss' param exists
  @feed = params[:feed]
  rss_content = ""
  open(@feed) do |f|
    rss_content = f.read
  end
  rss = RSS::Parser.parse(rss_content, false)
  # rss.items.size
  # rss.channel.description

  @printer.print_text ["#{rss.channel.title} (#{rss.channel.link})"]
  @printer.set_double_print_on
  puts rss.items[0].title
  puts cleanHTML(rss.items[0].title)
  @printer.print_text [cleanHTML(rss.items[0].title)]
  @printer.set_double_print_off
  @printer.set_print_mode_b
  @printer.print_text [cleanHTML(rss.items[0].description)]
  @printer.set_underline_on
  @printer.print_text [rss.items[0].link]
  @printer.set_underline_off
  @printer.print_text [rss.items[0].date.strftime("%B %d, %Y")]
  @printer.set_print_mode_a
  feed_and_cut
  "Feed: #{@feed}"
end

get '/print' do
   "Try /print?text=foo | /print?url=foo | /print?feed=foo"
end

get '/' do
  "try /print"
end

