class ArrowBullet < Bullet
    @@bullet_image = Rubygame::Surface.load_image("lib/bullets/arrow/bullet.png")
    @@explosion_image = Rubygame::Surface.load_image("lib/bullets/arrow/bullet_exp.png")

    def initialize pos, target

        # SUPER -> pos, target, bullet_image, explosion_image, damage, splash_range, move_rate
        super(
            pos,
            target
        );
    end

    def self.name
        "Arrow"
    end

    def self.bullet_image
        @@bullet_image
    end

    def self.explosion_image
        @@explosion_image
    end

    def self.damage
        40
    end

    def self.splash_range
        100
    end

    def self.move_rate
        30
    end
end
