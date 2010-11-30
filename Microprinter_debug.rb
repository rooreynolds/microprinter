class Microprinter_debug
  def initialize(port_str)
    puts "[Microprinter init]" 
  end

  def close
    puts "[Microprinter closing]"
  end

  # Feed this method either a string or an array of strings; each will be printed on its own line.
  def print_text(text)
    text.each do |line|
      print("[print]#{line}\n")
    end
  end

  def print(text)
    puts text
  end

  def feed 
    puts "[feed]\n\n\n"
  end

  def cut
    puts "[-----FULL CUT-----]"
  end

  def partial_cut
    puts "[-----PARTIAL CUT-----]"
  end  

  def set_print_mode_a
    puts "[set print mode a]"
  end

  def set_print_mode_b
    puts "[set print mode b]"
  end
  
  def set_double_print_on 
    puts "[set double print on]"
  end
  
  def set_double_print_off 
    puts "[set double print off]"
  end
  
  def set_underline_on 
    puts "[set underline on]"
  end
  
  def set_underline_off 
    puts "[set underline off]"
  end
  

end 


