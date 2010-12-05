require 'rubygems'
require './Microprinter.rb'
require 'RMagick'
include Magick

class ImageMicroprinter < Microprinter

  # mode = 0: width = 288
  # mode = 1: width = 576
  def print_image(image_path, dither = true, mode = 0)
    width = 288
    width = 576 if mode == 1 or mode == 21

    self.set_linefeed_rate(1)
    
    image = ImageList.new(image_path).first
    puts "cols = #{image.columns} rows = #{image.rows}"

    #if it's wider than max and wider than it is tall, rotate it
    if image.columns > width 
      rotated_image = image.rotate(90, ">")
      image = rotated_image if rotated_image
      puts "cols = #{image.columns} rows = #{image.rows}"
    end

    # apply fudge to fix elongated printout. 
    case mode
      when 0,20 then image = image.resize(image.columns, (0.69 * image.rows).to_i)
      when 1,21 then image = image.resize(image.columns, (0.345 * image.rows).to_i)
    end
    puts "cols = #{image.columns} rows = #{image.rows}"
    
    # enlarge canvas to width if it's smaller
    if image.columns < width 
      puts "enlarging canvas"
      bigger_canvas = Image.new(width, image.rows)
      image = bigger_canvas.composite(image, Magick::WestGravity, OverCompositeOp)
    end
  
    #reduce to max width if it's larger
    if image.columns > width 
      puts "resizing"
      image = image.resize_to_fit(width, 2000)
      puts "cols = #{image.columns} rows = #{image.rows}"
    end
  
    rows = image.rows
    cols = image.columns
    puts "cols = #{cols} rows = #{rows}"
  
    if dither
      image = image.quantize(2, Magick::GRAYColorspace)
    else
      #image = image.threshold(MaxRGB*0.5) #quantize is better
      image = image.quantize(2, Magick::GRAYColorspace, Magick::NoDitherMethod)
    end


    rowlimit = 8
    rowlimit = 24 if mode > 1
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
        print_image_row(mode, lbuffer)
        sleep(0.2)
        lbuffer = Array.new
      end
    end
    
    for i in (0 .. rowlimit - lbuffer.length)
      cbuffer = Array.new()
      for j in (0 .. width) 
        cbuffer.push(1)
      end
      lbuffer.push(cbuffer)
    end
    print_image_row(mode, lbuffer)
    
    self.set_linefeed_rate(22)
    self.feed
    self.feed
    # image.display # display on screen (requires X11. Useful for debugging)
    image.destroy! # tidy up after ourselves
  end

  def print_image_row(mode, data)
    bytes = Array.new
    if mode < 2
      for x in (0..data[0].length - 1)
        byte_column = data[0][x] << 7|data[1][x] << 6|data[2][x] << 5|data[3][x] << 4|data[4][x] << 3|data[5][x] << 2|data[6][x] << 1|data[7][x]
        bytes.push(byte_column ^ 255)
      end
    else 
      for x in (0..data[0].length - 1)
        byte_column = data[0][x] << 7|data[1][x] << 6|data[2][x] << 5|data[3][x] << 4|data[4][x] << 3|data[5][x] << 2|data[6][x] << 1|data[7][x]
        bytes.push(byte_column ^ 255)
        byte_column = data[8][x] << 7|data[9][x] << 6|data[10][x] << 5|data[11][x] << 4|data[12][x] << 3|data[13][x] << 2|data[14][x] << 1|data[15][x]
        bytes.push(byte_column ^ 255)
        byte_column = data[16][x] << 7|data[17][x] << 6|data[18][x] << 5|data[19][x] << 4|data[20][x] << 3|data[21][x] << 2|data[22][x] << 1|data[23][x]
        bytes.push(byte_column ^ 255)
      end
    end
    print_image_bytes(mode, bytes)
  end

end
