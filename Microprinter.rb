require 'rubygems'
require 'serialport'

class Microprinter 

  COMMAND = 0x1B
  FULLCUT = 0x69
  PARTIALCUT = 0x6D
  PRINT_MODE = 0x21
  DOUBLEPRINT = 0x47
  UNDERLINE = 0x2D

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

  def set_print_mode_a
    set_print_mode 0;
  end

  def set_print_mode_b
    set_print_mode 1;
  end

  def set_print_mode(i)
    @sp.putc COMMAND
    @sp.putc PRINT_MODE
    @sp.putc i
    @sp.flush
  end

  def set_double_print_on 
    set_double_print(0x01)
  end

  def set_double_print_off
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
  def print_text(text)
    text.each do |line|
      print("#{line}\n")
    end
  end
 
  def print(text)
    @sp.print(text)
    @sp.flush
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

end 

