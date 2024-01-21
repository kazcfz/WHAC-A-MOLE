require 'gosu'

module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end

class GameWindow < Gosu::Window

def initialize
    super 1280, 720, false
	self.caption = "Whac-A-Mole"
	
	# Menu Screens #
	@background_image = Gosu::Image.new("media/maps/map1.png")
	@mole_image = Gosu::Image.new("media/entity/defaultmole.png")
	@mainmenu = Gosu::Image.new("media/menu/mainmenu.png")
	@gameover = Gosu::Image.new("media/menu/gameover.png")
	@scorescreen = Gosu::Image.new("media/menu/score.png")
	@scorescreen_gameover = Gosu::Image.new("media/menu/score_gameover.png")
	
	# Menu Buttons #
	@play_button = Gosu::Image.new("media/buttons/play.png")
	@score_button = Gosu::Image.new("media/buttons/score.png")
	@quit_button = Gosu::Image.new("media/buttons/quit.png")
	@replay_button = Gosu::Image.new("media/buttons/replay.png")
	@savescore_button = Gosu::Image.new("media/buttons/savescore.png")
	@saved_idle_button = Gosu::Image.new("media/buttons/saved_idle.png")
	@saved_mouseover_button = Gosu::Image.new("media/buttons/saved_mouseover.png")
	@menu_button = Gosu::Image.new("media/buttons/menu.png")
	@back_button = Gosu::Image.new("media/buttons/back.png")
	
	# Ready, Set, Whack Images #
	@ready_image = Gosu::Image.new("media/readysetwhack/ready.png")
	@set_image = Gosu::Image.new("media/readysetwhack/set.png")
	@whack_image = Gosu::Image.new("media/readysetwhack/whack.png")
	
	# Music and sounds #
	@menu_music = Gosu::Song.new("media/sound/MerryGo.mp3")
	@menu_music.volume = 0.15
	@play_music = Gosu::Song.new("media/sound/MonkeysSpinningMonkeys.mp3")
	@play_music.volume = 0.6
	@hit_sound = Gosu::Sample.new("media/sound/hit.mp3")
	@buttonclick_sound = Gosu::Sample.new("media/sound/click.ogg")
	
	@font = Gosu::Font.new(35)
	
	@whichmenu = "mainmenu"
	@score = 0
	@mole_position = 0
	@prevmole_position = 0
	@x = -500
	@y = -500
	@hit = 0
	@moletime = 2
	@gametime30 = 30 + 2	# 2 sec prep-time
	@restarttime = @gametime30
	@playing = 0
	@saved = 0
	
	@ready = @gametime30
	@set = @gametime30 - 1
	@whack = @gametime30 - 2
end

# Used for when user starts or restarts a game.
def startorrestart
	@buttonclick_sound.play
	@playing = 1
	@score = 0
	@gametime30 = @restarttime + (Gosu.milliseconds/1000)
	@moletime = 2 + (Gosu.milliseconds/1000)
	@whichmenu = nil
	@saved = 0
end

# Used when user quits the game through the 'QUIT' button.
def quit
	@buttonclick_sound.play
	sleep(0.2)
	abort "\nExiting...\n"
end

# Codes for operating the game when started. 
def gameinitialize(moletimer)
	if (@playing == 1)
		@gametime = @gametime30 - (Gosu.milliseconds/1000)
		@play_music.play(true)
		
	elsif (@playing == 0)
		@gametime = 0
		@x = -500
		@y = -500
		@play_music.stop
	end
	
	# Moves the mole every 2 seconds or when it's hit.
	if (@gametime > 0) && (@playing == 1)
	
		if ((moletimer == 0) || (@hit == 1))
			
			while (@prevmole_position == @mole_position)
				# The random number that determines the mole's location.
				@mole_position = rand(6)
			end
			@prevmole_position = @mole_position
		
			@moletime = (Gosu.milliseconds/1000)
			@hit = 0
		
			if (@mole_position == 0)
				@x = 161
				@y = 158
				@moletime += 2
		
			elsif (@mole_position == 1)
				@x = 545
				@y = 158
				@moletime += 2
		
			elsif (@mole_position == 2)
				@x = 929
				@y = 158
				@moletime += 2
		
			elsif (@mole_position == 3)
				@x = 161
				@y = 414
				@moletime += 2
		
			elsif (@mole_position == 4)
				@x = 545
				@y = 414
				@moletime += 2
		
			elsif (@mole_position == 5)
				@x = 929
				@y = 414
				@moletime += 2
	
			end
		end
	else
	@playing = 0
	if (@whichmenu == nil)
		@whichmenu = "gameover" # Shows "Game Over" menu when game ends.
	end
	end
end

def update
	# Keeps track of the timer for the mole (2 seconds).
	moletimer = @moletime - (Gosu.milliseconds/1000)
	gameinitialize(moletimer)
end


### (START) Read and Print highscore ###
class Highscore
	attr_accessor :sname, :sscore
	def initialize(savedname, savedscore)
		@sname = savedname
		@sscore = savedscore
	end
end

def main_readhighscore
	highscorefile = File.new("highscore.txt", "r")
	if highscorefile
		highscores = readhighscores(highscorefile)
		highscorefile.close
	else
		puts "Unable to open file to read!"
	end
	printhighscores(highscores)
end

def readhighscores(highscorefile)
	count = highscorefile.gets.chomp.to_i
	loop = 1
	highscores = Array.new
	
	while (loop <= count)
		highscore = readhighscore(highscorefile)
		highscores << highscore
		loop += 1
	end
	highscores
end

def readhighscore (highscorefile)
	myhighscore = Highscore.new(@sname, @sscore)
	myhighscore.sname = highscorefile.gets
	myhighscore.sscore = highscorefile.gets
	return myhighscore
end

def printhighscores(highscores)
	loop = 0
	tx = 100
	ty = 90
	while (loop < highscores.length)
		printhighscore (highscores[loop]), tx, ty
		loop += 1
		ty += 100
		if (loop % 5 == 0) 
			tx += 400
			ty = 90
		end
		if (loop > 15)
			@font.draw_text("Can only display 15 scores", 900, 675, z = ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
		end
	end
end

def printhighscore(highscores, tx, ty)
	@font.draw_text("\nName: #{highscores.sname}Score: #{highscores.sscore}", tx, ty, z = ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
end
### Read and Print highscore (END) ###

# Saves the user's name and score, and stores it into a text file
def main_writehighscore
	puts "\nPlease enter your name: "
	username = gets.chomp
	puts "\nScore saved!"
	
	highscorefile = File.new("highscore.txt", "a")
	highscorefile.puts(username)
	highscorefile.puts(@score)
	highscorefile.close
	
	highscorefile = File.new("highscore.txt", "r")
	count = highscorefile.gets.chomp.to_i
	countplus = count + 1
	highscorefile.close
	
	# First line of the text file is rewritten to plus 1 when a new score is saved.
	# So that it can read that latest score the next time the file is read.
	count_line = File.readlines("highscore.txt")
	count_line[0] = countplus.to_s << $/
	File.open("highscore.txt", "w") { |f| f.write(count_line.join) }
	
	@saved = 1
end


def button_down(id)
	if (id == Gosu::MsLeft)
		
		### MAIN MENU ###
		if (@whichmenu == "mainmenu")
			if ((mouse_x > 496 && mouse_x < 783) && (mouse_y > 192 && mouse_y < 287))
				startorrestart
			elsif ((mouse_x > 496 && mouse_x < 783) && (mouse_y > 320 && mouse_y < 415))
				@whichmenu = "score"
				@buttonclick_sound.play
			elsif ((mouse_x > 496 && mouse_x < 783) && (mouse_y > 448 && mouse_y < 543))
				quit
			end
		end
		
		### SCORE ###
		if (@whichmenu == "score")
			if ((mouse_x > 496 && mouse_x < 783) && (mouse_y > 602 && mouse_y < 697))
				@whichmenu = "mainmenu"
				@buttonclick_sound.play
			end
		end
		
		### SCORE (Game Over) ###
		if (@whichmenu == "score_gameover")
			if ((mouse_x > 496 && mouse_x < 783) && (mouse_y > 602 && mouse_y < 697))
				@whichmenu = "gameover"
				@buttonclick_sound.play
			end
		end
		
		### MOLE HIT ###
        if (@playing == 1) && (Gosu.distance(mouse_x, mouse_y, @x+86, @y+120) < 100)
			@score += 1
			@hit = 1
			@hit_sound.play(0.75)
		else
			@hit = 0
		end
		
		### GAME OVER ###
		if (@whichmenu == "gameover")
			if ((mouse_x > 272 && mouse_x < 559) && (mouse_y > 529 && mouse_y < 624))
				startorrestart
			elsif ((mouse_x > 721 && mouse_x < 1008) && (mouse_y > 529 && mouse_y < 624))
				quit
			elsif ((mouse_x > 496 && mouse_x < 783) && (mouse_y > 368 && mouse_y < 463))
				@whichmenu = "score_gameover"
				@buttonclick_sound.play
			elsif ((mouse_x > 496 && mouse_x < 783) && (mouse_y > 256 && mouse_y < 351))
				@buttonclick_sound.play
				if (@saved == 0)
					main_writehighscore
				else
					puts "\nYou have already saved your score!"
				end
			end
		end
	end
end


# Returns true or false value if or if not the mouse coordinates are within the area.
def mouse_over?(x1, y1, x2, y2)
	((mouse_x >= x1) && (mouse_y >= y1)) && ((mouse_x <= x2) && (mouse_y <= y2))
end

# Displays the default mouse cursor on GUI.
def needs_cursor?; true; end

def draw
	@background_image.draw(0, 0, z = ZOrder::BACKGROUND)
	draw_menu
	draw_molestart
end

def draw_menu
	### MAIN MENU ###
	if (@whichmenu == "mainmenu")
		@menu_music.play(true)
		@mainmenu.draw(0, 0, z = ZOrder::MIDDLE)
		if mouse_over?(496, 192, 783, 287)
			@play_button.draw(496, 192, z = ZOrder::TOP)
		elsif mouse_over?(496, 320, 783, 415)
			@score_button.draw(496, 320, z = ZOrder::TOP)
		elsif mouse_over?(496, 448, 783, 543)
			@quit_button.draw(496, 448, z = ZOrder::TOP)
		end
	end
	
	### GAME OVER ###
	if (@whichmenu == "gameover")
		@gameover.draw(0, 0, z = ZOrder::MIDDLE)
		@menu_music.play(true)
		@font.draw_text("Score: #{@score}", 579, 175, z = ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
		if mouse_over?(272, 529, 559, 624)
			@replay_button.draw(272, 529, z = ZOrder::TOP)
		elsif mouse_over?(721, 529, 1008, 624)
			@quit_button.draw(721, 529, z = ZOrder::TOP)
		elsif mouse_over?(496, 256, 783, 351)
			@savescore_button.draw(496, 256, z = ZOrder::TOP)
		elsif mouse_over?(496, 368, 783, 463)
			@score_button.draw(496, 368, z = ZOrder::TOP)
		end
		
		# Changes button from 'Save Score' to 'Saved!' when user has saved score.
		if (@saved == 1)
			@saved_idle_button.draw(496, 256, z = ZOrder::TOP)
			if mouse_over?(496, 256, 783, 351)
				@saved_mouseover_button.draw(496, 256, z = ZOrder::TOP)
			end
		end
	end
	
	### SCORE ###
	if (@whichmenu == "score")
		main_readhighscore
		@scorescreen.draw(0, 0, z = ZOrder::MIDDLE)
		if mouse_over?(496, 602, 783, 697)
			@menu_button.draw(496, 602, z = ZOrder::TOP)
		end
	end
	
	### SCORE (Game Over) ###
	if (@whichmenu == "score_gameover")
		main_readhighscore
		@scorescreen_gameover.draw(0, 0, z = ZOrder::MIDDLE)
		if mouse_over?(496, 602, 783, 697)
			@back_button.draw(496, 602, z = ZOrder::TOP)
		end
	end
end

def draw_molestart
	# Draws Score and Timer in text during gameplay.
	if (@playing == 1) && (@gametime <= @whack)
		@font.draw_text("Score: #{@score}", 10, 10, z = ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
		@font.draw_text("Time: #{@gametime}", 579, 10, z = ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
	end
	
	# Draws 'Ready, Set, Whack!'.
	if (@gametime == @ready)
		@ready_image.draw(0, 0, z = ZOrder::MIDDLE)
	elsif (@gametime == @set)
		@set_image.draw(0, 0, z = ZOrder::MIDDLE)
	elsif (@gametime == @whack)
		@whack_image.draw(0, 0, z = ZOrder::MIDDLE)
	end
	
	# Draws the moles to their coordinated holes according to the random generated number.
	if (@mole_position == 0)
		@mole_image.draw(@x, @y, z = ZOrder::MIDDLE)
		
	elsif (@mole_position == 1)
		@mole_image.draw(@x, @y, z = ZOrder::MIDDLE)
		
	elsif (@mole_position == 2)
		@mole_image.draw(@x, @y, z = ZOrder::MIDDLE)
		
	elsif (@mole_position == 3)
		@mole_image.draw(@x, @y, z = ZOrder::MIDDLE)
		
	elsif (@mole_position == 4)
		@mole_image.draw(@x, @y, z = ZOrder::MIDDLE)
		
	elsif (@mole_position == 5)
		@mole_image.draw(@x, @y, z = ZOrder::MIDDLE)
	end
end


end

window = GameWindow.new
window.show