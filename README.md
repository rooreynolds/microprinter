Microprinter Arduino library, Java and Ruby API
===============================================

<http://rooreynolds.com/category/microprinter/>  
<http://microprinter.pbworks.com/>  

Contents
--------

 - microprinter_sketch.pde - an arduino sketch  
 - Microprinter.java - a java class to communicate with the arduino  
 - Microprinter.rb - a ruby class to communicate with the arduino  
 - Microprinter_debug.rb - ruby class which prints to console rather than printer  
 - microbroker-sinatra - sinatra app   
     usage: `ruby -rubygems microprinter-sinatra.rb`  
       `http://localhost:4567/print/weather`  
       `http://localhost:4567/print?text=test text`  
       `http://localhost:4567/print?feed=http://rooreynolds.com/feed/`  

Elsewhere: 
---------
  Ben O'Steen has a [Python port of the library][pymicro]. 
  
[pymicro]: https://github.com/benosteen/microprinter/
  
TODO
----

In no particular order, some things to be done:

-   check RSS feeds and print new items as they appear  
    Examples: twitter, latest links on pinboard.in, latest instapaper items…
-   make URL for weather reports configurable so it's not hard coded to south of england (!)
-   create a config file for arduino port, RSS feeds, weather location
-   re-integrate debug library into microprinter.rb - pipe serial messages to console for debugging and automated testing. 
-   format the RSS feed item printout to shorten the URL and print properly so that it can be OCR'd with Google Goggles
-   possibly port Ben O'Steen's image stuff so that you can print QRCodes on links, as well as images. 