require 'rubygems'
require 'sinatra'
require 'rss'
require 'open-uri'
require 'cgi'

require 'sqlite3'
require 'hpricot'
require 'open-uri'

#require './Microprinter_debug.rb' # uncomment this to print to the console instead of the printer. 
require './Microprinter.rb' 

set :arduinoport, "/dev/cu.usbserial-A1001NFW" # or whatever yours is. 
#set :arduinoport, "/dev/cu.usbmodem24131" # or whatever yours is. 

before do
  #@printer = Microprinter_debug.new(settings.arduinoport)
  @printer = Microprinter.new(settings.arduinoport)
  @printer.set_character_width_normal
end

def cleanHTML(text)
  newtext = text
  newtext.gsub! "&\#8211;", "-" #replace em-dash
  newtext.gsub! "&\#8216;", "'" # replace curly quotes
  newtext.gsub! "&\#8217;", "'"
  newtext.gsub! "&\#8230;", "..."
  newtext.gsub! "&\#176;", "\xF8"
  newtext.gsub! "°", "\xF8" # °
  newtext.gsub! "£", "\x9C" # £
  return newtext
end 

def printList(db, title, sql, narrow = false)
  @printer.set_double_print_on
  @printer.print_text title
  @printer.set_double_print_off
  @printer.set_character_width_narrow if (narrow)
  db.execute(sql) do |row|
    
  #TODO: only print header if list contains any items

    areastring = "[] "
        if (row['project']) then
            areastring += row['project'] + ": "
        elsif (row['area']) then
          areastring += row['area'] + ": "
        end
        #@printer.set_double_print_on
        @printer.print areastring
        #@printer.set_double_print_off
        printtext = (row['title'])[0, ((narrow ? 64 : 48) - areastring.length)] #64 for narrow, 48 for wide font
        @printer.print_text printtext
  end
  @printer.set_character_width_normal if (narrow)
  @printer.print "\n"
end

def printDate
  @printer.print_text Time.now.localtime.strftime("%A, %d %B %Y")
  @printer.print "\n"
end

def printWeather (narrow = false)
  @printer.set_double_print_on
  @printer.print_text "Weather - Southampton"
  @printer.set_double_print_off
  @printer.set_character_width_narrow if (narrow)
  
  @feed = "http://open.live.bbc.co.uk/weather/feeds/en/2637487/3dayforecast.rss"
  rss_content = ""
  open(@feed) do |f|
    rss_content = f.read
  end
  rss = RSS::Parser.parse(rss_content, false)
  text = rss.items[0].description
  text.gsub!(", ","\n")
  if (narrow) 
    text.gsub!("\nWind Speed",", Wind Speed")
    text.gsub!("\nPressure",", Pressure")
    text.gsub!("\nHumidity",", Humidity")
    text.gsub!("\nPollution",", Pollution")
    text.gsub!("\nSunset",", Sunset")
  else
    text.gsub!("\nVisibility","  Visibility")
    text.gsub!("\nHumidity","  Humidity")
    text.gsub!("\nPollution","  Pollution")
  end
  @printer.print_text [cleanHTML(text)]

  doc = Hpricot(open('http://www.bbc.co.uk/weather/2637487').read) # https://github.com/hpricot/hpricot/wiki/hpricot-basics
  @printer.set_double_print_on
  @printer.print_text((doc/"//div[@class='title']")[0].innerHTML)
  @printer.set_double_print_off
  @printer.print_text((doc/"//div[@class='body']")[0].innerHTML)
  @printer.set_double_print_on
  if ((doc/"//div[@class='title']")[1].innerHTML) 
    @printer.print_text((doc/"//div[@class='title']")[1].innerHTML)
    @printer.set_double_print_off
    @printer.print_text((doc/"//div[@class='body']")[1].innerHTML)
  end
  
  #TODO: what happens when there are more than one forecast section? show both

  #TODO: temp and summary of NOW via now-summary and temperature-value-unit-c http://www.bbc.co.uk/weather/2637487/location-now-weather/
  @printer.set_character_width_normal if (narrow)
  "Printed the weather"
  @printer.print "\n"
end

def printThings(narrow = false)
  db = SQLite3::Database.new("/Users/rooreynolds/Library/Application Support/Cultured Code/Things beta/ThingsLibrary.db")
  db.results_as_hash = true
  printList(db, "Actions - Review", "select ZTHING.ZTITLE as title, " \
    "date(ZTHING.ZSTARTDATE, 'unixepoch', '+31 years', 'localtime') as startdate, " \
    "AREA.ZTITLE as area, PROJECT.ZTITLE as project " \
    "from ZTHING " \
    "LEFT OUTER JOIN ZTHING PROJECT on ZTHING.ZPROJECT = PROJECT.Z_PK " \
    "LEFT OUTER JOIN ZTHING AREA on ZTHING.ZAREA = AREA.Z_PK " \
    "WHERE startdate <= date('now') and ZTHING.ZSTARTDATE != '' and ZTHING.ZSTATUS != 3 and ZTHING.ZTRASHED = 0 and ZTHING.ZSTART = 2 " \
    "ORDER BY ZTHING.ZINDEX;", narrow)
  printList(db, "Actions - Today", "select ZTHING.ZTITLE as title, " \
    "AREA.ZTITLE as area, PROJECT.ZTITLE as project, " \
    "date(ZTHING.ZCREATIONDATE, 'unixepoch', '+31 years', 'localtime') as createdate, " \
    "round(julianday(date('now')) - julianday(datetime(ZTHING.ZCREATIONDATE, 'unixepoch', '+31 years', 'localtime')),20) as age " \
    "FROM ZTHING " \
      "LEFT OUTER JOIN ZTHING PROJECT on ZTHING.ZPROJECT = PROJECT.Z_PK " \
      "LEFT OUTER JOIN ZTHING AREA on ZTHING.ZAREA = AREA.Z_PK " \
      "WHERE ZTHING.ZSTARTDATE != '' and ZTHING.ZSTATUS != 3 and ZTHING.ZTRASHED = 0 and ZTHING.ZSTART = 1 " \
    "ORDER BY ZTHING.ZTODAYINDEX;", narrow)
  printList(db, "Actions - Tomorrow", "select date(ZTHING.ZSTARTDATE, 'unixepoch', '+31 years', 'localtime') as date, " \
      "AREA.ZTITLE as area, PROJECT.ZTITLE as project, " \
    "ZTHING.ZTITLE as title FROM ZTHING " \
      "LEFT OUTER JOIN ZTHING PROJECT on ZTHING.ZPROJECT = PROJECT.Z_PK " \
      "LEFT OUTER JOIN ZTHING AREA on ZTHING.ZAREA = AREA.Z_PK " \
    "WHERE date = date('now', '+1 day') and ZTHING.ZSTARTDATE != '' and ZTHING.ZSTATUS != 3 and ZTHING.ZTRASHED = 0 and ZTHING.ZSTART = 2;", narrow)
  @printer.feed_and_cut
end

def printTrains(narrow = false)
  @printer.set_double_print_on
  @printer.print_text "Trains"
  @printer.set_double_print_off

  @printer.set_character_width_narrow if (narrow)
  
  
  doc = Hpricot(open('http://ojp.nationalrail.co.uk/service/ldbboard/dep/SOA/WAT/To').read)
  table = doc.search("//table")
  (table/"tr").each { |tr_item|
    time = nil
    status = nil
    platform = nil
    tr_item.search("//td").each { |td_item|
        time = td_item.innerHTML if (! time)
        status = td_item.innerHTML if td_item.attributes['class'] == 'status';
        platform = td_item.innerHTML if td_item.attributes['class'] == 'status';
        
    }
    if (status) 
      @printer.print_text time + " - " + status
    end
  }
  
  doc = Hpricot(open('http://www.journeycheck.southwesttrains.co.uk/southwesttrains/route?from=SOA&to=WAT&action=search').read)
  @printer.print_text((doc/"#portletDivBodygeneralUpdatesLineUpdate"/"div/div").first.innerHTML.gsub(/<script.*?>[\s\S]*<\/script>/i, "").gsub(/<[^>]*>/ui,'').gsub(/\s+/, " ").strip)
  @printer.print_text((doc/"#portletDivBodygeneralUpdatesTrainCancellation"/"div/div").first.innerHTML.gsub(/<script.*?>[\s\S]*<\/script>/i, "").gsub(/<[^>]*>/ui,'').gsub(/\s+/, " ").strip)
  @printer.print_text((doc/"#portletDivBodygeneralUpdatesOtherTrainAlteration"/"div/div").first.innerHTML.gsub(/<script.*?>[\s\S]*<\/script>/i, "").gsub(/<[^>]*>/ui,'').gsub(/\s+/, " ").strip)
  @printer.print_text((doc/"#portletDivBodygeneralUpdatesToStationUndergroundUpdate"/"div/div")[1].innerHTML.strip.gsub(/<script.*?>[\s\S]*<\/script>/i, "").gsub(/<[^>]*>/ui,'').gsub(/\s+/, " ").gsub(" but there are planned disruptions", "").split(".").shift)
  @printer.print "\n"
  "done"

  @printer.set_character_width_normal if (narrow)

  #TODO: take a look at http://www.tfl.gov.uk/tfl/livetravelnews/realtime/tube/default.html#

end

get '/print/cut' do
  @printer.cut
  "cut"
end 

get '/print/barcode' do
  @printer.set_barcode_width(Microprinter::BARCODE_WIDTH_MEDIUM)
  @printer.set_barcode_height(45)
  @printer.set_barcode_text_position(Microprinter::BARCODE_TEXT_BELOW)
  @printer.print_barcode("/2009/02/22/")
  @printer.feed_and_cut
  "Printed sample barcode"
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
      when "upca" then @printer.print_barcode(params[:barcode], Microprinter::BARCODE_MODE_UPCA)
      when "upce" then @printer.print_barcode(params[:barcode], Microprinter::BARCODE_MODE_UPCE)
      when "jan13aen" then @printer.print_barcode(params[:barcode], Microprinter::BARCODE_MODE_JAN13AEN)
      when "jan8ean" then @printer.print_barcode(params[:barcode], Microprinter::BARCODE_MODE_JAN8EAN)
      when "code39" then @printer.print_barcode(params[:barcode], Microprinter::BARCODE_MODE_CODE39)
      when "itf" then @printer.print_barcode(params[:barcode], Microprinter::BARCODE_MODE_ITF)
      when "codeabar" then @printer.print_barcode(params[:barcode], Microprinter::BARCODE_MODE_CODEABAR)
      when "code128" then @printer.print_barcode(params[:barcode], Microprinter::BARCODE_MODE_CODE128)
    end
  else 
    @printer.print_barcode(params[:barcode])
  end
  @printer.feed_and_cut
  "Printed barcode #{params[:barcode]}"
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
   "Try /print?text=foo | /print?url=foo | /print?feed=foo | /print/cut /print/barcode/x | /print/cut"
end

get '/' do
  "try /print"
end

get '/print/date' do
  "printing date"
  printDate
end

get '/print/weather' do
  "printing weather"
  printWeather  
end

get '/print/dailydump' do
  @printer.set_character_width_normal
  narrow = true
  printDate
  printWeather(narrow)
  printTrains(narrow)
  printThings(narrow)
end

get '/print/todo' do
  printThings
end

get '/print/trains' do
  printTrains
end

#http://localhost:4567/print?feed=http://open.live.bbc.co.uk/weather/feeds/en/2637487/3dayforecast.rss
