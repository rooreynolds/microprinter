require 'rubygems'
require './Microprinter.rb'
require 'RMagick'
include Magick

class ImageMicroprinter < Microprinter

  def print_image(image_path, dither = true)
    self.set_linefeed_rate(1)
    
    image = ImageList.new(image_path).first
    #puts "cols = #{image.columns} rows = #{image.rows}"

    #if it's wider than 288 and wider than it is tall, rotate it
    if image.columns > 288
      rotated_image = image.rotate(90, ">")
      image = rotated_image if rotated_image
      #puts "cols = #{image.columns} rows = #{image.rows}"
    end
    
    # apply fudge to fix elongated printout. 
    image = image.resize(image.columns, (0.69 * image.rows).to_i) 
    #puts "cols = #{image.columns} rows = #{image.rows}"
    
    # enlarge canvas to 288 width if it's smaller
    if image.columns < 288
      #puts "enlarging canvas"
      bigger_canvas = Image.new(288, image.rows)
      image = bigger_canvas.composite(image, Magick::WestGravity, OverCompositeOp)
    end
  
    #reduce to max 288 width if it's larger
    if image.columns > 288
      #puts "resizing to max 288x2000"
      image = image.resize_to_fit(288, 2000)
      #puts "cols = #{image.columns} rows = #{image.rows}"
    end
  
    rows = image.rows
    cols = image.columns
    #puts "cols = #{cols} rows = #{rows}"
  
    if dither
      image = image.quantize(2, Magick::GRAYColorspace)
    else
      #image = image.threshold(MaxRGB*0.5) #quantize is better
      image = image.quantize(2, Magick::GRAYColorspace, Magick::NoDitherMethod)
    end
  
    rowcount = 0
    rowlimit = 8
    lbuffer = Array.new
    rows.times do |y|
      cbuffer = Array.new
      cols.times do |x|
        pixel = image.pixel_color(x, y)
        ##puts "#{x}\t#{y}\t#{pixel}"
        if (pixel.red.to_i == MaxRGB) 
          cbuffer.push(1)
        else
          cbuffer.push(0)
        end
      end
      lbuffer.push(cbuffer)
      if lbuffer.length == rowlimit
        ###puts (lbuffer.to_s)
        print_image_row(lbuffer)
        sleep(0.01)
        lbuffer = Array.new
      end
      sleep(0.01)
    end
    
    self.set_linefeed_rate(22)
    self.feed
    self.feed
    #image.display # display on screen (requires X11. Useful for debugging)
    image.destroy! # tidy up after ourselves
  end

  def print_image_row(data)
    mode = 0
    bytes = Array.new
    for x in (0..data[0].length - 1)
      byte_column = data[0][x] << 7|data[1][x] << 6|data[2][x] << 5|data[3][x] << 4|data[4][x] << 3|data[5][x] << 2|data[6][x] << 1|data[7][x]
      bytes.push(byte_column ^ 255)
    end
    print_image_bytes(mode, bytes)
  end

end
