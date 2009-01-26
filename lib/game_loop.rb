# Author: Robert Pyke

class Setup

    
    @@title_font = Rubygame::SFont.new("resources/NeonFont.png")

    def initialize
        screen_size = [1100,800]
        @screen = Screen.new(screen_size, 0, [Rubygame::HWSURFACE,Rubygame::DOUBLEBUF])
        @queue = Rubygame::EventQueue.new()
        @clock = Rubygame::Clock.new()
        @clock.target_framerate = 60
        @control = Controller.new(@screen, @clock)
        puts "Warning, sound disabled" unless ($sound_ok = (VERSIONS[:sdl_mixer] != nil ))
        puts "Using audio driver:" + Rubygame.audio_driver
    end
    
    def run
        print_title "Press ENTER to start the game"
        @screen.update
        loop do
            @queue.each do |ev|
                case ev
                when Rubygame::QuitEvent
                    Rubygame.quit()
                    exit
                when Rubygame::KeyDownEvent
                    case ev.key
                    when Rubygame::K_ESCAPE
                        Rubygame.quit()
                        exit
                    when Rubygame::K_RETURN
                        @control.run()
                    end
                end
            end
        @clock.tick()
        end
    end
   
    def print_title(string)
        text = @@title_font.render(string)
        text.blit(@screen,[(@screen.width / 2 - text.width / 2), @screen.height / 2 - text.height / 2])
    end
end

class Controller
    @@minimum_screen_size = [400, 400]
    @@title_font = Rubygame::SFont.new("resources/NeonFont.png")
    @@description_font = Rubygame::SFont.new("resources/NeonFont2.png")
    @@status_font = @@description_font

    def initialize screen, clock
        @screen = screen
        @queue = Rubygame::EventQueue.new()
        @clock = clock
        @built_towers = {}
        @selected_tower = nil
        @bullets = []
        @bugs = []
        @frames_until_next_wave = 500
        @next_wave_lasts_x_frames = @frames_until_next_wave - (@frames_until_next_wave / 100)
        @next_wave_size = 20
        validate_screen_size
        @max_x = 800 unless screen.width <= 800
        @max_x = screen.width - 100 if screen.width <= 800
        @max_y = 800 unless screen.width <= 800
        @max_y = screen.height - 100 if screen.height <= 800
        @score = 0
        @money = 2000    # Start with 2000
        @lives = 50
        @palette = [
            ArcherTower, LightningTower 
        ]
        @palette_grid = {}
        @status_messages = []
        setup_palette_grid 
        @frames_since_last_status_change = 0
    end

    def validate_screen_size
        if @screen.width < @@minimum_screen_size[0] or @screen.height < @@minimum_screen_size[1]
            raise "Screen dimension too small. Screen size: #{@screen.width}, #{@screen.height}. Minimum screen size: #{@@minimum_screen_size[0]}, #{@@minimum_screen_size[1]}."
        end
    end

    def run
        @level = DemoLevel.new()
            
        background = Surface.new(@screen.size)
        background_image = @level.background_image          # Image clearer / background
        background_image.blit(background, [0,0])

        donger_sound = Sound.load "resources/donger.wav"
        clang_sound = Sound.load "resources/clang.wav"

        # Change the music to something nicer.
        # background_music = Music.load "resources/ff7_one_winged_angel.mp3"
        
        # This shows how many frames to show the banned tower locations for.  
        show_banned_timer = 0

        create_bug_wave

        loop do
            @queue.each do |ev|
                case ev
                    when Rubygame::QuitEvent
                        Rubygame.quit()
                    exit
                    
                    
                    when Rubygame::KeyDownEvent
                        case ev.key
                            when Rubygame::K_ESCAPE
                                Rubygame.quit()
                            exit                            
                        end                                    

                    when Rubygame::MouseDownEvent                        
                        case ev.button                            
                            when Rubygame::MOUSE_LEFT
                                x = ev.pos[0]/50 * 50
                                y = ev.pos[1]/50 * 50
                                pos = [x,y]                        
                                if @level.banned_positions[pos] and @selected_tower
                                    clang_sound.play
                                    @status_messages << "Can't build at: #{pos[0]}, #{pos[1]}. Reason: #{@level.banned_positions[pos]}"
                                    show_banned_timer = 60 # 60 frames... About 1 second
                                else
                                    # Build the tower if, there is no tower there already, a tower from the palette has been selected, and the click is in range
                                    if !@built_towers[pos] and @selected_tower and x < @max_x and y < @max_y and @money >= @selected_tower.price
                                        @built_towers[pos] = @selected_tower.new(pos)
                                        @status_messages << "Built tower at: #{pos[0]}, #{pos[1]}."
                                        @money -= @selected_tower.price
                                    end
                                
                                end

                                item_clicked = @palette_grid[[x,y]]
                                @selected_tower = item_clicked if item_clicked
                            when Rubygame::MOUSE_RIGHT
                                x = ev.pos[0]/50 * 50
                                y = ev.pos[1]/50 * 50
                                pos = [x,y]
                                
                                if @built_towers[pos]
                                    @money += ( @built_towers[pos].class.price * 0.8 ).to_i
                                    @built_towers.delete(pos)
                                else
                                    if @selected_tower
                                        @selected_tower = nil
                                    else
                                        @status_messages << "NO TOWER FOUND AT #{pos[0]}, #{pos[1]}."
                                    end
                                end
                        end

                    when Rubygame::MouseMotionEvent
                        # TODO fix this slow operation..
                        @built_towers.each do |pos, tower|
                                tower.hover(false)
                        end

                        x = ev.pos[0]/50 * 50
                        y = ev.pos[1]/50 * 50
                        pos = [x,y]
                        over_tower = @built_towers[pos]
                        over_tower.hover(true) if over_tower
                end
            end     

            background.blit(@screen,[0,0])
            
            @built_towers.each do |pos, tower| 
                tower.image.blit(@screen, pos)
            end
        
            update_towers

            fire

            draw_towers
            
            update_bullets
            
            update_bugs

            draw_bugs

            draw_bullets           
            
            draw_palette

            show_banned_timer -= 1

            draw_banned_positions if show_banned_timer > 1

            description_to_print = ( @selected_tower.description + @selected_tower.bullet_class.description ) if @selected_tower != nil 
            print_description(description_to_print) if @selected_tower

            @frames_until_next_wave -= 1
            if @frames_until_next_wave <= 0
                create_bug_wave
            end

            if @lives <= 0
                puts @score
                exit 
            end

            cleanup

            draw_status


            fps_update()
            @screen.update()
            @clock.tick()
        end
    end

    def fps_update()
        @screen.title = "FPS: #{@clock.framerate()}"
    end

    def cleanup
        @built_towers.each do |pos, tower|
            tower.cleanup
        end

        @bugs.each do |bug|
            if bug.dead 
                @bugs.delete bug
                @score += 1
            elsif bug.fin
                @bugs.delete bug
                @lives -= 1
            end
        end 
    end

    def draw_status
        # Approx 3 seconds at target frame-rate
        if @status_messages[0] != nil
            print_status @status_messages[0] if @status_messages[0] != nil
            if @frames_since_last_status_change > 180
                @status_messages.delete @status_messages[0]
                @frames_since_last_status_change = 0
            end
        else
            print_status "Score: #{@score}, Lives Left: #{@lives}, Money: #{@money}."
        end
        @frames_since_last_status_change += 1
    end

    def setup_palette_grid
        x = @max_x
        y = 0

        @palette.each do |item|
            # This item will be drawn from x, y
            @palette_grid[[x,y]] = item
            
            x += 50
            if x >= @screen.width
                x = @max_x
                y += 50 
            end
        end
    end

    def draw_palette
        @palette_grid.each do |pos, item|
            item.palette_image_selected.blit(@screen, pos) if item == @selected_tower
            item.palette_image_deselected.blit(@screen, pos) unless item == @selected_tower
        end
    end

    def print_title(string)
        text = @@title_font.render(string)
        text.blit(@screen,[(@screen.width / 2 - text.width / 2), 0])
    end

    def print_description(lines)
        max_x = 0
        max_y = 0

        multi = lines.size + 1
        lines.each do |string|
            #multi -= 1
            text = @@description_font.render(string)
            max_x = text.width if text.width > max_x 
            max_y = text.height if text.height > max_y
        end

        lines.each do |string|
            multi -= 1
            text = @@description_font.render(string)
            x = @screen.width - max_x - 10   # Ten for a buffer from the edge
            y = @screen.height - (max_y * multi) - 10
            text.blit(@screen,[x, y])
        end
    end

    def print_status(string)
        text = @@status_font.render(string)
        text.blit(@screen,[0, ( @screen.height - ( text.height * 2 ))]) 
    end

    def draw_towers
        @built_towers.each do |pos, tower| 
            tower.image.blit(@screen, pos)
        end
    end

    def update_towers
        @built_towers.each do |pos, tower|
            tower.update
        end
    end

    def create_bug_wave 
        waypoints = @level.get_wave_waypoints 

	# Assume there is at least one waypoint in the waypoints array
        @next_wave_size.times do
            # Spawn within about 15% of the first waypoint
		# puts waypoints[0]
            x = waypoints[0][0]    
            left = rand(2)  # left is either 0 or 1
            delta_hor = 1 + rand(@max_x * 0.15)
            if left == 1
                x -= delta_hor
            else 
                x+= delta_hor
            end
            y = waypoints[0][1]
            up = rand(2)        # up is either 0 or 1 
            delta_ver = 1 + rand(@max_y * 0.15)
            if up == 1
                y -= delta_ver
            else 
                y += delta_ver
            end
            @bugs << Bug.new([x,y], waypoints)
        end

        @frames_until_next_wave = @next_wave_lasts_x_frames
        @next_wave_lasts_x_frames -= @next_wave_lasts_x_frames * 0.03       # 3 % less time between each wave.

        @next_wave_size +=  (@next_wave_size * 0.1).to_i 
        @lives += 1                                                         # Gain a life every wave.
        @money += ( @money * 0.1).to_i                                           # Gain 10% interest       
        @money += ( @next_wave_size / 2 ).to_i                                   # One dollar for every 2 enemies you will need to destroy
    end

    def fire
        @built_towers.each do |pos, tower|
            @bugs.each do |bug| 
                tower.fire_if_can bug.pos_c
            end
        end
    end

    def update_bullets
        @built_towers.each do |pos, tower|
            tower.update_bullets
        end
    end

    def update_bugs
        @bugs.each do |bug|
            bug.update
            # Check if any bugs are within the range of any exploding bullets
            @built_towers.each do |pos, tower|
                tower.exploding_bullets.each do |bullet|
                    bug.health -= bullet.class.damage if bullet.in_splash_range bug.pos_c
                    bug.dead = true unless bug.health > 0  
                end
            end
        end
    end

    def draw_bullets
        @built_towers.each do |pos, tower|     
            tower.bullets.each do |bullet| 
                bullet.image.blit(@screen, bullet.pos)
            end
        end
    end

    def draw_bugs
        @bugs.each do |bug|
            bug.image.blit(@screen, bug.pos)
        end 
    end

    def draw_banned_positions
        banned_position_image = Surface.load_image("resources/banned_position.png")
        @level.banned_positions.each do |key, value|
            banned_position_image.blit(@screen, key)      
        end
    end

end

