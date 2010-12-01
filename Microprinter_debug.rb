# TODO: turn this debug library into an rspec mock/stub; when testing, send serial data to a stub, so that we can test for expected responses, etc. 

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

  def feed_and_cut
    self.feed
    self.cut
  end
  
  def print_and_cut(text) # utility method. print line (or array of lines) then feed & cut
    self.print_text(text)
    self.feed_and_cut
  end

  def set_character_width_normal
    puts "[set print mode a (normal width text)]"
  end

  def set_character_width_narrow
    puts "[set print mode b (narrow width text)]"
  end

  def set_print_mode_a
    set_character_width_normal
  end

  def set_print_mode_b
    set_character_width_narrow
  end

  
  def set_font_weight_bold 
    puts "[set double print on (bold text)]"
  end
  
  def set_double_print_on 
    set_font_weight_bold
  end
  
  def set_font_weight_normal
    puts "[set double print off (normal weight text)]"
  end
  
  def set_double_print_off 
    set_font_weight_normal
  end
  
  def set_underline_on 
    puts "[set underline on]"
  end
  
  def set_underline_off 
    puts "[set underline off]"
  end
  

end 


