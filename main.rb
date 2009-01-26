#Author: Robert Pyke

require "rubygems"
require "rubygame"
require "rubygame/sfont"
require "lib/game_loop.rb"
require "lib/towers/tower.rb"
require "lib/towers/archer_tower/archer_tower.rb"
require "lib/towers/lightning_tower/lightning_tower.rb"
require "lib/bullets/bullet.rb"
require "lib/bullets/arrow/arrow.rb"
require "lib/bullets/lightning/lightning.rb"
require "lib/bugs/bug.rb"
require "lib/levels/level.rb"
require "lib/levels/demo_level/demo_level.rb"

include Rubygame

TTF.setup
setup = Setup.new()
setup.run()
