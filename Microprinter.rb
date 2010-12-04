require 'rubygems'
require 'serialport'

class Microprinter 

  COMMAND = 0x1B
  FULLCUT = 0x69
  PARTIALCUT = 0x6D
  PRINT_MODE = 0x21
  DOUBLEPRINT = 0x47
  UNDERLINE = 0x2D

  COMMAND_BARCODE = 0x1D
  COMMAND_BARCODE_PRINT = 0x6B
  COMMAND_BARCODE_WIDTH = 0x77
  COMMAND_BARCODE_HEIGHT = 0x68
  COMMAND_BARCODE_TEXTPOSITION = 0x48
  COMMAND_BARCODE_FONT = 0x66

  BARCODE_WIDTH_NARROW = 0x02
  BARCODE_WIDTH_MEDIUM = 0x03
  BARCODE_WIDTH_WIDE = 0x04

  BARCODE_TEXT_NONE = 0x00
  BARCODE_TEXT_ABOVE = 0x01
  BARCODE_TEXT_BELOW = 0x02
  BARCODE_TEXT_BOTH = 0x03

  BARCODE_MODE_UPCA = 0x00
  BARCODE_MODE_UPCE = 0x01
  BARCODE_MODE_JAN13AEN = 0x02
  BARCODE_MODE_JAN8EAN = 0x03
  BARCODE_MODE_CODE39 = 0x04
  BARCODE_MODE_ITF = 0x05
  BARCODE_MODE_CODEABAR = 0x06
  BARCODE_MODE_CODE128 = 0x07

  def initialize(port_str = "/dev/cu.usbserial-A1001NFW")  
    @port_str = port_str 
    baud_rate = 9600
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE
    @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    sleep(2)  # give arduino a chance to restart
  end
  
  def close
    @sp.flush
    @sp.close
  end 

  # Standard font: 42 characters per line if using 80mm paper  
  def set_character_width_normal
    set_print_mode 0;
  end

  def set_print_mode_a
    set_character_width_normal
  end
  
  # Narrow font, more characters per line
  def set_character_width_narrow
    set_print_mode 1;
  end

  def set_print_mode_b
    set_character_width_narrow
  end

  def set_print_mode(i)
    @sp.putc COMMAND
    @sp.putc PRINT_MODE
    @sp.putc i
    @sp.flush
  end
  
  # Bold weight text
  def set_double_print_on 
    # set_double_print(0x01)
    set_font_weight_bold
  end

  # Maintain backwards compatibility...
  def set_font_weight_bold
    # set_double_print_on
    set_double_print(0x01)     
  end

  # Normal weight text
  def set_double_print_off
    # set_double_print(0x00)
    set_font_weight_normal
  end

  # Maintain backwards compatibility...
  def set_font_weight_normal
    set_double_print(0x00)
  end
  

  def set_double_print(i)
    @sp.putc COMMAND
    @sp.putc DOUBLEPRINT 
    @sp.putc i
    @sp.flush
  end 

  def set_underline_on 
    set_underline(1)
  end

  def set_underline_off 
    set_underline(0)
  end

  def set_underline(i) # n = 0, 1 or 2 dot underline
    @sp.putc COMMAND
    @sp.putc UNDERLINE
    @sp.putc i
    @sp.flush
  end


  # Feed this method either a string or an array of strings; each will be printed on its own line.
  # TODO: should be able to feed this method a long string with line endings, and have it print properly, the same way you can feed `erb` or `haml` a set of lines in sinatra. 
  def print_text(text)
    text.each do |line|
      print("#{line}\n")
    end
  end
 
  def print(text)
    @sp.print(text)
    @sp.flush
  end

  def feed_and_cut # utility method. 
    self.feed
    self.cut
  end
  
  def print_and_cut(text) # utility method. print line (or array of lines) then feed & cut
    self.print_text(text)
    self.feed_and_cut
  end

  def feed() 
    @sp.print("\n")
    @sp.print("\n")
    @sp.print("\n")
    @sp.print("\n")
    @sp.flush
  end

  def cut()
    @sp.putc COMMAND
    @sp.putc FULLCUT
    @sp.flush
  end

  def partial_cut()
    @sp.putc COMMAND
    @sp.putc PARTIALCUT
    @sp.flush
  end

  def print_barcode(barcode_mode = BARCODE_MODE_CODE39, barcode)
    @sp.putc COMMAND_BARCODE
    @sp.putc COMMAND_BARCODE_PRINT
    @sp.putc barcode_mode 
    @sp.print barcode
    @sp.putc 0x00
    @sp.flush
  end

  def set_barcode_height(height) # in dots. default = 162
    height = 0 if (height.to_i < 0)
    @sp.putc COMMAND_BARCODE
    @sp.putc COMMAND_BARCODE_HEIGHT
    @sp.putc height.to_i 
    @sp.flush
  end

  def set_barcode_width(width) 
    @sp.putc COMMAND_BARCODE
    @sp.putc COMMAND_BARCODE_WIDTH
    @sp.putc width
    @sp.flush
  end

  def set_barcode_text_position(position) 
    position = 0 if (position.to_i < 0)
    position = 3 if (position.to_i > 3)
    @sp.putc COMMAND_BARCODE 
    @sp.putc COMMAND_BARCODE_TEXTPOSITION
    @sp.putc position 
    @sp.flush
  end

end 

