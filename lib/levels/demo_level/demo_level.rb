# Author: Robert Pyke
class DemoLevel < Level
    def initialize
        super(
            Rubygame::Surface.load("lib/levels/demo_level/background_800x800.png"),
            [
                [   # Path 1
                    [700, 75],
                    [85, 70],
                    [80, 380],
                    [250, 400],
                    [615, 390],
                    [615, 690],
                    [615, 690],
		    [85, 680]
                ],
                [   #Path 2
 		    [12, 260],
                    [80, 260],
                    [80, 380],
                    [250, 400],
                    [615, 390],
                    [615, 690],
                    [615, 690],
		    [85, 680]
                ]
            ],
            {}
        )
        # Use the helper method to create banned build points
        setup_banned_points_between_waypoints     
    end
end
