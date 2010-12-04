require 'rubygems'
require 'sinatra'
require 'rss'
require 'open-uri'
require 'cgi'
# require './Microprinter_debug.rb' # uncomment this to print to the console instead of the printer. 
require './Microprinter.rb' 

set :arduinoport, "/dev/cu.usbserial-A1001NFW" # or whatever yours is. 
# set :arduinoport, "/dev/cu.usbmodem24131" # or whatever yours is. 

before do
#  @printer = Microprinter_debug.new(settings.arduinoport)
  @printer = Microprinter.new(settings.arduinoport)
  @printer.set_character_width_normal
end

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
  @printer.print_and_cut weather_content.split("\n")
  "Weather printed"
end

get '/print/barcode/:barcode' do
  @printer.set_barcode_height(params[:height]) if params[:height] 
  case params[:width] 
    when "narrow" then @printer.set_barcode_width(Microprinter::BARCODE_WIDTH_NARROW)
    when "medium" then @printer.set_barcode_width(Microprinter::BARCODE_WIDTH_MEDIUM)
    when "wide" then @printer.set_barcode_width(Microprinter::BARCODE_WIDTH_WIDE)
  end

  case params[:position] 
    when "below" then @printer.set_barcode_text_position(Microprinter::BARCODE_TEXT_BELOW)
    when "above" then @printer.set_barcode_text_position(Microprinter::BARCODE_TEXT_ABOVE)
    when "both" then @printer.set_barcode_text_position(Microprinter::BARCODE_TEXT_BOTH)
    when "none" then @printer.set_barcode_text_position(Microprinter::BARCODE_TEXT_NONE)
  end

  if params[:mode]
    case params[:mode]
      when "upca" then @printer.print_barcode(Microprinter::BARCODE_MODE_UPCA, params[:barcode])
      when "upce" then @printer.print_barcode(Microprinter::BARCODE_MODE_UPCE, params[:barcode])
      when "jan13aen" then @printer.print_barcode(Microprinter::BARCODE_MODE_JAN13AEN, params[:barcode])
      when "jan8ean" then @printer.print_barcode(Microprinter::BARCODE_MODE_JAN8EAN, params[:barcode])
      when "code39" then @printer.print_barcode(Microprinter::BARCODE_MODE_CODE39, params[:barcode])
      when "itf" then @printer.print_barcode(Microprinter::BARCODE_MODE_ITF, params[:barcode])
      when "codeabar" then @printer.print_barcode(Microprinter::BARCODE_MODE_CODEABAR, params[:barcode])
      when "code128" then @printer.print_barcode(Microprinter::BARCODE_MODE_CODE128, params[:barcode])
    end
  else 
    @printer.print_barcode(params[:barcode])
  end
  @printer.feed_and_cut
  "Printed barcode #{params[:barcode]}"
end

get '/print/barcode2' do
  @printer.set_barcode_width(Microprinter::BARCODE_WIDTH_MEDIUM)
  @printer.set_barcode_height(45)
  @printer.set_barcode_text_position(Microprinter::BARCODE_TEXT_BELOW)
  @printer.print_barcode("/2009/02/22/")
end

get '/print' do
  pass unless params[:text] # use this rule if 'text' param exists
  @text = params[:text]
  @printer.print_and_cut [@text, "", request.url]
  "Text: #{@text}"
end

get '/print' do
  pass unless params[:url] # use this rule if 'url' param exists
  @url = params[:url]
  #TODO: do some processing...

  #TODO: maybe use a regex to identify URLs, rather than explicity ask for a ?url= param? 
  # Something like this, from http://daringfireball.net/2010/07/improved_regex_for_matching_urls
  # (?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))

  # From sinatra readme (http://www.sinatrarb.com/intro.html)
  # Route matching with Regular Expressions:

  #   get %r{/hello/([\w]+)} do
  #     "Hello, #{params[:captures].first}!"
  #   end

  # Or with a block parameter:
  # 
  #   get %r{/hello/([\w]+)} do |c|
  #     "Hello, #{c}!"
  #   end

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
  # useful: rss.items.size, rss.channel.description, ...
  @printer.print_text ["#{rss.channel.title} (#{rss.channel.link})"]
  @printer.set_font_weight_bold
  @printer.print_text [cleanHTML(rss.items[0].title)]
  @printer.set_font_weight_normal
  @printer.set_character_width_narrow
  @printer.print_text [cleanHTML(rss.items[0].description)]
  @printer.set_underline_on
  @printer.print_text [rss.items[0].link]
  @printer.set_underline_off
  @printer.print_text [rss.items[0].date.strftime("%B %d, %Y")]
  @printer.set_character_width_normal
  @printer.feed_and_cut
  "Printed first item from feed: #{@feed}"
end

get '/print' do
   "Try /print?text=foo | /print?url=foo | /print?feed=foo"
end

get '/' do
  "try /print"
end

get '/linkformat' do
  
end
