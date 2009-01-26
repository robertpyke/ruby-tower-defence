# Author: Robert Pyke

class ArcherTower < Tower
    @@tower_image = Rubygame::Surface.load_image("lib/towers/archer_tower/tower.png") 
    @@hover_image = Rubygame::Surface.load_image("lib/towers/archer_tower/hover.png")  
    @@palette_image_selected = Rubygame::Surface.load_image("lib/towers/archer_tower/hover.png")
    @@palette_image_deselected = Rubygame::Surface.load_image("lib/towers/archer_tower/tower.png") 

    def initialize pos
        super(pos);
    end
   
    def self.name
        "Archer Tower"
    end

    def self.palette_image_selected
        @@palette_image_selected
    end

    def self.palette_image_deselected
        @@palette_image_deselected
    end

    def self.bullet_class
        ArrowBullet
    end

    def self.price
        500
    end
    
    def self.tower_image
        @@tower_image
    end

    def self.hover_image
        @@hover_image
    end
    
    def self.radius
        500
    end

    def self.time_between_shots
        50
    end
end
