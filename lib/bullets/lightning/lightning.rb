class LightningBullet < Bullet

    @@bullet_image = Rubygame::Surface.load_image("lib/bullets/lightning/bullet.png")
    @@explosion_image = Rubygame::Surface.load_image("lib/bullets/lightning/bullet_exp.png")
        
    def initialize pos, target
            super(
                pos,
                target
            );
    end

    def self.name
        "Lightning"
    end

    def self.bullet_image
        @@bullet_image
    end

    def self.explosion_image
        @@explosion_image
    end

    def self.damage
        10
    end

    def self.splash_range
        15
    end

    def self.move_rate
        20
    end
end

