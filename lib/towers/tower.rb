# Author: Robert Pyke
# File: tower.rb

class Tower 

    attr_reader :pos, :pos_c, :image, :bullets
    
    def initialize  pos
        validate_tower
        @image = self.class.hover_image
        @turns_since_last_fired = 0        # This means the tower will need to wait one shot's worth of time before going
        @pos = [pos[0], pos[1]]
        @bullets = []
        x = pos[0] + ( @image.width / 2 )
        y = pos[1] + ( @image.height / 2 )
        @pos_c = [x,y]
    end

    def validate_tower
        im_1_valid = ( self.class.tower_image.height == 50 and self.class.tower_image.width == 50 )
        im_2_valid = ( self.class.hover_image.height == 50 and self.class.hover_image.width == 50 ) 
        im_3_valid = ( self.class.palette_image_selected.height == 50 and self.class.palette_image_selected.width == 50)
        im_4_valid = ( self.class.palette_image_deselected.height == 50 and self.class.palette_image_deselected.width == 50 )
        if !(im_1_valid and im_2_valid and im_3_valid and im_4_valid )
            raise "Tower not valid, images must be 50x50."
        end
    end

    def hover(hovered_over)
        if(hovered_over)
            @image = self.class.hover_image
        else
            @image = self.class.tower_image
        end
    end

    def update
        @turns_since_last_fired += 1
    end

    def fired
        @turns_since_last_fired = 0
    end

    def can_fire
        return_value = ( @turns_since_last_fired > self.class.time_between_shots )
        return return_value
    end


    def fire_if_can target
        if can_fire                 # Don't bother looking at the target if we can't fire.
            x_diff = target[0] - @pos_c[0]
            y_diff = target[1] - @pos_c[1]

            c_sq = x_diff**2 + y_diff**2
            c = Math.sqrt(c_sq)

            if c <= self.class.radius
                fired
                @bullets << self.class.bullet_class.new(@pos_c, target)
            end
        end
    end


    # Remove any exploded bullets from the tower's bullets.
    def cleanup 
        @bullets.each do |bullet|
            if bullet.exploding
                @bullets.delete bullet
            end
        end
    end

    def update_bullets
        @bullets.each do |bullet|
            bullet.update
        end
    end
   
    def exploding_bullets
        exp_bullets = []
        @bullets.each do |bullet|
            exp_bullets << bullet if bullet.exploding
        end
        exp_bullets
    end

    def self.name
        return "MUST BE OVERRIDDEN"
    end

    def self.description 
        # Optionally, override in child class
        # An array of lines
        return [
                "#{name}", 
                "    Cost: #{price}",
                "    Range: #{radius}", 
                "    Frames between shots: #{time_between_shots}"
        ]
    end

    def self.palette_image_selected
        raise "MUST BE OVERRIDDEN"
    end

    def self.palette_image_deselected
        raise "MUST BE OVERRIDDEN"
    end

    def self.bullet_class
        raise "MUST BE OVERRIDDEN"
    end

    def self.price
        raise "MUST BE OVERRIDDEN"
    end

    def self.tower_image
        raise "MUST BE OVERRIDDEN"
    end

    def self.hover_image
        raise "MUST BE OVERRIDDEN"
    end
    
    def self.radius
        raise "MUST BE OVERRIDDEN"
    end

    def self.time_between_shots
        raise "MUST BE OVERRIDDEN"
    end

end

