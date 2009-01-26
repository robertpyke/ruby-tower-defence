
class Bullet
    attr_reader :pos, :target, :move_rate, :image, :exploding
       

    def initialize pos, target
        @pos = [pos[0], pos[1]]
        @target = [target[0], target[1]]
        @exploding = false
        @image = self.class.bullet_image
        
        # Calculate x movement rate and y movement rate.
        x_diff = pos[0] - target[0]
        y_diff = pos[1] - target[1]

        if x_diff == 0 and y_diff == 0 
            @x_mov = 0
            @y_mov = 0
        else
            c_sq = x_diff**2 + y_diff**2
            c = Math.sqrt(c_sq)
            @x_mov = - ( (x_diff /  c) * self.class.move_rate)
            @y_mov = - ( (y_diff /  c) * self.class.move_rate)
        end
    end

    def pos_c
        x = pos[0] + (@image.width / 2)
        y = pos[1] + (@image.height / 2)
        return [x,y] 
    end

    def update
        # If the bullet is within the bullet move_rate of the target, assume it has hit. 
        x_diff = pos[0] - target[0]
        y_diff = pos[1] - target[1]
        
        c_sq = x_diff**2 + y_diff**2
        c = Math.sqrt(c_sq)
        
        # If it is within mov_rate, explode at the target, otherwise move the bullet the move rate.
        if c <= self.class.move_rate
            explode
        else
            @pos[0] += @x_mov
            @pos[1] += @y_mov
        end

    end

    def explode
        @pos = target
        @exploding = true
        @image = self.class.explosion_image
    end

    def in_splash_range target
        x_diff = pos_c[0] - target[0]
        y_diff = pos_c[1] - target[1]

        c_sq = x_diff**2 + y_diff**2
        c = Math.sqrt(c_sq)

        if c <= self.class.splash_range
            return true        
        else 
            return false
        end
    end


    def self.description 
        # Optionally, override in child class
        # An array of lines
        return [
                "#{name}", 
                "    Damage: #{damage}",
                "    Splash range: #{splash_range}", 
                "    Movement rate: #{move_rate}"
        ]
    end

    def self.bullet_image
        raise "MUST BE OVERRIDDEN"
    end

    def self.explosion_image
        raise "MUST BE OVERRIDDEN"
    end

    def self.name
        raise "MUST BE OVERRIDDEN"
    end

    def self.damage
        raise "MUST BE OVERRIDDEN"
    end

    def self.spash_range
        raise "MUST BE OVERRIDDEN"
    end

    def self.move_rate
        raise "MUST BE OVERRIDDEN"
    end

end
