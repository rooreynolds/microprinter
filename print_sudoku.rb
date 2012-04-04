require './Microprinter.rb' 
require 'doku'
require 'enumerator'

@printer = Microprinter.new()

def print_sudoku(puzzle)
	puts puzzle
	g = Hash.new("   ")
	puzzle.glyph_state.each { |square, glyph| g[[square.y, square.x]] = " " + glyph.to_s + " "}
	margin = "     "
	spac3 = "   "
	horiz = "\xC4"
	horzD = "\xCD"
	horz3 = "\xC4" + "\xC4" + "\xC4"
	hrzD3 = "\xCD" + "\xCD" + "\xCD"
	vertc = "\xB3"
	vertD = "\xBA"
	cross = "\xC5"
	crosD = "\xCE"
	lcros = "\xC7" #C3
	lcrsD = "\xCC"
	rcros = "\xB6" #B4
	rcrsD = "\xB9"
	tcros = "\xD1" #C2
	tcrsD = "\xCB"
	bcros = "\xCF" #C1
	bcrsD = "\xCA"
	crsDH = "\xD8"
	crsDV = "\xD7"
	tplft = "\xC9" #DA
	btlft = "\xC8" #C0
	tprgt = "\xBB" #BF
	btrgt = "\xBC" #D9
	@printer.set_linefeed_rate 48
	@printer.print_line margin + tplft + hrzD3 + tcros + hrzD3 + tcros + hrzD3 + tcrsD + hrzD3 + tcros + hrzD3 + tcros + hrzD3 + tcrsD + hrzD3 + tcros + hrzD3 + tcros + hrzD3 + tprgt
	@printer.print_line margin + vertD + g[[0,0]] + vertc + g[[0,1]] + vertc + g[[0,2]] + vertD + g[[0,3]] + vertc + g[[0,4]] + vertc + g[[0,5]] + vertD + g[[0,6]] + vertc + g[[0,7]] + vertc + g[[0,8]] + vertD  
	@printer.print_line margin + lcros + horz3 + cross + horz3 + cross + horz3 + crsDV + horz3 + cross + horz3 + cross + horz3 + crsDV + horz3 + cross + horz3 + cross + horz3 + rcros
	@printer.print_line margin + vertD + g[[1,0]] + vertc + g[[1,1]] + vertc + g[[1,2]] + vertD + g[[1,3]] + vertc + g[[1,4]] + vertc + g[[1,5]] + vertD + g[[1,6]] + vertc + g[[1,7]] + vertc + g[[1,8]] + vertD
	@printer.print_line margin + lcros + horz3 + cross + horz3 + cross + horz3 + crsDV + horz3 + cross + horz3 + cross + horz3 + crsDV + horz3 + cross + horz3 + cross + horz3 + rcros  
	@printer.print_line margin + vertD + g[[2,0]] + vertc + g[[2,1]] + vertc + g[[2,2]] + vertD + g[[2,3]] + vertc + g[[2,4]] + vertc + g[[2,5]] + vertD + g[[2,6]] + vertc + g[[2,7]] + vertc + g[[2,8]] + vertD
	@printer.print_line margin + lcrsD + hrzD3 + crsDH + hrzD3 + crsDH + hrzD3 + crosD + hrzD3 + crsDH + hrzD3 + crsDH + hrzD3 + crosD + hrzD3 + crsDH + hrzD3 + crsDH + hrzD3 + rcrsD  
	@printer.print_line margin + vertD + g[[3,0]] + vertc + g[[3,1]] + vertc + g[[3,2]] + vertD + g[[3,3]] + vertc + g[[3,4]] + vertc + g[[3,5]] + vertD + g[[3,6]] + vertc + g[[3,7]] + vertc + g[[3,8]] + vertD
	@printer.print_line margin + lcros + horz3 + cross + horz3 + cross + horz3 + crsDV + horz3 + cross + horz3 + cross + horz3 + crsDV + horz3 + cross + horz3 + cross + horz3 + rcros  
	@printer.print_line margin + vertD + g[[4,0]] + vertc + g[[4,1]] + vertc + g[[4,2]] + vertD + g[[4,3]] + vertc + g[[4,4]] + vertc + g[[4,5]] + vertD + g[[4,6]] + vertc + g[[4,7]] + vertc + g[[4,8]] + vertD
	@printer.print_line margin + lcros + horz3 + cross + horz3 + cross + horz3 + crsDV + horz3 + cross + horz3 + cross + horz3 + crsDV + horz3 + cross + horz3 + cross + horz3 + rcros  
	@printer.print_line margin + vertD + g[[5,0]] + vertc + g[[5,1]] + vertc + g[[5,2]] + vertD + g[[5,3]] + vertc + g[[5,4]] + vertc + g[[5,5]] + vertD + g[[5,6]] + vertc + g[[5,7]] + vertc + g[[5,8]] + vertD
	@printer.print_line margin + lcrsD + hrzD3 + crsDH + hrzD3 + crsDH + hrzD3 + crosD + hrzD3 + crsDH + hrzD3 + crsDH + hrzD3 + crosD + hrzD3 + crsDH + hrzD3 + crsDH + hrzD3 + rcrsD  
	@printer.print_line margin + vertD + g[[6,0]] + vertc + g[[6,1]] + vertc + g[[6,2]] + vertD + g[[6,3]] + vertc + g[[6,4]] + vertc + g[[6,5]] + vertD + g[[6,6]] + vertc + g[[6,7]] + vertc + g[[6,8]] + vertD
	@printer.print_line margin + lcros + horz3 + cross + horz3 + cross + horz3 + crsDV + horz3 + cross + horz3 + cross + horz3 + crsDV + horz3 + cross + horz3 + cross + horz3 + rcros  
	@printer.print_line margin + vertD + g[[7,0]] + vertc + g[[7,1]] + vertc + g[[7,2]] + vertD + g[[7,3]] + vertc + g[[7,4]] + vertc + g[[7,5]] + vertD + g[[7,6]] + vertc + g[[7,7]] + vertc + g[[7,8]] + vertD
	@printer.print_line margin + lcros + horz3 + cross + horz3 + cross + horz3 + crsDV + horz3 + cross + horz3 + cross + horz3 + crsDV + horz3 + cross + horz3 + cross + horz3 + rcros  
	@printer.print_line margin + vertD + g[[8,0]] + vertc + g[[8,1]] + vertc + g[[8,2]] + vertD + g[[8,3]] + vertc + g[[8,4]] + vertc + g[[8,5]] + vertD + g[[8,6]] + vertc + g[[8,7]] + vertc + g[[8,8]] + vertD
	@printer.print_line margin + btlft + hrzD3 + bcros + hrzD3 + bcros + hrzD3 + bcrsD + hrzD3 + bcros + hrzD3 + bcros + hrzD3 + bcrsD + hrzD3 + bcros + hrzD3 + bcros + hrzD3 + btrgt

	webstring = "http://www.sudokuwiki.org/sudoku.htm?bd="
	for i in (0...9)
		for j in (0...9)
			glyph = g[[i, j]].strip
			if (glyph == "")
      			glyph = "."
    		end
    		webstring += glyph.to_s
		end
	end
	return webstring
end

# technique for generating seed sudoku borrowed from http://rubyquiz.strd6.com/quizzes/182-sudoku-generator
puzzle = [0] * 81
a = (1..9).sort_by{rand}  #generate a 'seed' with three boxes populated
b = (1..9).sort_by{rand}
c = (1..9).sort_by{rand}

puzzle[0..2] = a[0..2]
puzzle[9..11] = a[3..5]
puzzle[18..20] = a[6..8]

puzzle[30..32] = b[0..2]
puzzle[39..41] = b[3..5]
puzzle[48..50] = b[6..8]

puzzle[60..62] = c[0..2]
puzzle[69..71] = c[3..5]
puzzle[78..80] = c[6..8]

puzzlestring = "" # turn it into something that Doku can parse
puzzle.each_slice(9){|row|
  row.each {|glyph|  
    if (glyph == 0)
      glyph = "."
    end
    puzzlestring += glyph.to_s
  }
  puzzlestring += "\n"
}

puzzle = Doku::Sudoku.new(puzzlestring) # Doku is rather nice for solving sodoku
print_sudoku(puzzle) # but first, show the seed puzzle
@printer.feed
puzzle = puzzle.solve # now show the solved puzzle
print_sudoku(puzzle)
@printer.feed

i = 0
solutions = 1
filled = 81
oldpuzzle = puzzle
holes = Hash.new(false) # where have we previously made holes?

n = 10 # how many to attempt to remove each pass

candidates = Hash.new
puzzle.glyph_state.each { |square, glyph| candidates[[square.x, square.y]] = glyph.to_s}

# todo: vary difficulty by varying remaining squares theshold (puzzle.glyph_state.count below)
while(puzzle.glyph_state.count > 30 && candidates.size > 0) do  # blank out enough squares to make it interesting, but give up if we can't remove any more
	newholes = Hash.new(false)
	n.times{
		if (candidates.size > 0) # can't keep going if we run out of possible squares to blank
	  	candidate = candidates.keys[rand(candidates.size)]
	  	x = candidate[0]
	  	y = candidate[1]
	  	if (n == 1) # keep track of the available choices only when we start to struggle
	  		candidates.delete(candidate)
	  	end
	  	puzzle.set(x,y,nil)
	  	newholes[[x,y]] = true
		end
	}
  solutions = puzzle.solutions.count
  filled = puzzle.glyph_state.count
  if (solutions > 1) # more than one solution. Not a valid sodoku. back out
  	puts ("   " + i.to_s + "\t" + n.to_s + "\t" + solutions.to_s + "\t" + filled.to_s + "\t" + candidates.size.to_s + "\t" + holes.size.to_s)
  	puzzle = oldpuzzle.clone
  	if (n > 1) 
  		n = n - 1
  	end
  else 
  	holes = holes.merge(newholes)
  	oldpuzzle = puzzle.clone # keep backup
  	puts ("** " + i.to_s + "\t" + n.to_s + "\t" + solutions.to_s + "\t" + filled.to_s + "\t" + candidates.size.to_s + "\t" + holes.size.to_s + "\t(+" + newholes.length.to_s + ")")
  end
  i = i + 1
end

print_sudoku(puzzle.solve) # show it can still be solved
@printer.feed_and_cut

helpurl = print_sudoku(puzzle) # show the incomplete puzzle
@printer.feed_and_cut

puts
puts puzzle.solutions.count.to_s + " possible solutions"
puts "took " + i.to_s + " iterations to make"
puts "puzzle has " + filled.to_s + " clues"
puts "puzzle has " + holes.size.to_s + " holes"
puts "online help " + helpurl

# test difficulties: 
#http://www.sudokuwiki.org/sudoku.htm
#http://www.websudoku.com/?level=3
#http://www.menneske.no/sudoku/eng/random.html?start=18&stop=18
# tips:
#http://www.sudokuoftheday.com/pages/techniques-overview.php
#http://www.angusj.com/sudoku/hints.php
