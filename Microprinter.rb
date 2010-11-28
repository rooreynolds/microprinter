require 'rubygems'
require 'serialport'

class Microprinter 

  COMMAND = 0x1B
  FULLCUT = 0x69
  PARTIALCUT = 0x6D

  def initialize(port_str = "/dev/cu.usbserial-A1001NFW")  
    @port_str = port_str 
    baud_rate = 9600
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE
    @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    sleep(3)  # give arduino a chance to restart
  end  
  
  def close
    @sp.flush
    @sp.close              
  end 
 
  def print(text)
    @sp.print(text)
  end

  def feed() 
    @sp.print("\n\n\n");
  end

  def cut()
    @sp.putc COMMAND;
    @sp.putc FULLCUT;
  end

  def partial_cut()
    @sp.putc COMMAND;
    @sp.putc PARTIALCUT;
  end

end 

p = Microprinter.new("/dev/cu.usbserial-A1001NFW")
p.print("Hello there\n")
p.print("Line the second\n")
p.feed
p.cut
p.close

