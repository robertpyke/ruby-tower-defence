# Author: Robert Pyke

class LightningTower < Tower
    @@tower_image = Rubygame::Surface.load_image("lib/towers/lightning_tower/tower.png")
    @@hover_image = Rubygame::Surface.load_image("lib/towers/lightning_tower/hover.png") 
    @@palette_image_selected = Rubygame::Surface.load_image("lib/towers/lightning_tower/hover.png")
    @@palette_image_deselected = Rubygame::Surface.load_image("lib/towers/lightning_tower/tower.png") 
    
    def initialize pos
        super(pos);
    end
   
    def self.name
        "Lightning Tower"
    end

    def self.palette_image_selected
        @@palette_image_selected
    end

    def self.palette_image_deselected
        @@palette_image_deselected
    end

    def self.bullet_class
        LightningBullet
    end

    def self.price
        250
    end

    def self.tower_image
        return @@tower_image
    end

    def self.hover_image
        return @@hover_image
    end
    
    def self.radius
        return 200
    end

    def self.time_between_shots
        return 1
    end
end
