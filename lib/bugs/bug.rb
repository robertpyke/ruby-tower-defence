class Bug

    attr_reader :current_waypoint, :waypoints
    attr_accessor :pos, :dead, :health, :fin
    
    @@alive_image = Rubygame::Surface.load_image("lib/bugs/bug.png")
    @@dead_image = Rubygame::Surface.load_image("lib/bugs/dead_bug.png")


    def initialize pos, waypoints
        @pos = [pos[0], pos[1]]
        @waypoints = waypoints
        @@move_rate = 2 
        @dead = false
        @fin = false
        @health = 1000
        @current_waypoint = 0
    end
      
    def update
        up = false
        right = true

        if ( @pos[0] > @waypoints[@current_waypoint][0] )
            right = false
        elsif ( @pos[0] <= @waypoints[@current_waypoint][0] )
            right = true
        end

        if ( @pos[1] >= @waypoints[@current_waypoint][1] )
            up = true
        elsif ( @pos[1] <= @waypoints[@current_waypoint][1] )
            up = false
        end

        if right
            delta = ( 1 + rand(@@move_rate))
            @pos[0] += delta
        else
            delta = ( 1 + rand(@@move_rate))
            @pos[0] -= delta
        end

        if up
            @pos[1] -= (1 + rand(@@move_rate))
        else
            @pos[1] += (1 + rand(@@move_rate))
        end


        x_diff = pos[0] - @waypoints[@current_waypoint][0]
        y_diff = pos[1] - @waypoints[@current_waypoint][1]

        c_sq = x_diff**2 + y_diff**2
        c = Math.sqrt(c_sq)

        if c <= @@move_rate
            if @waypoints[@current_waypoint + 1] != nil
                @current_waypoint += 1
            else
                # No waypoints left, we are at the end.
                @fin = true
            end
        end

    end

    def image
        if !@dead
            return @@alive_image
        else
            return @@dead_image
        end

    end
    
    def pos_c
        x = pos[0] + (image.width / 2)
        y = pos[1] + (image.height / 2)
        return [x, y]
    end
end
