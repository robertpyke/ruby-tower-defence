class Level
    attr_reader :background_image, :waypoints_array, :banned_positions
        
    @@grid_magnitude = 10

    def initialize background_image, waypoints_array, banned_positions
        @background_image = background_image
	raise "Level has no waypoint paths in waypoints_array. We need at least one waypoint path to play" if waypoints_array.size == 0 
        @waypoints_array = waypoints_array
        @banned_positions = banned_positions
    end

    # Call this method to add banneed position along the waypoints path
    def setup_banned_points_between_waypoints
        # Step along the path of the waypoints,
        # each step is of size grid magnitude.
        # Ban the position we arrive at for each step.
	
        @waypoints_array.each do |spec_waypoints|
            i = 0
            position = [spec_waypoints[i][0], spec_waypoints[i][1] ]    # Start at the first position of the waypoint.
            waypoint = spec_waypoints[i]
            
            while waypoint != nil
                x_diff = position[0] - waypoint[0]
                y_diff = position[1] - waypoint[1]

                c_sq = x_diff**2 + y_diff**2
                c = Math.sqrt(c_sq)
                x_mov = - ( (x_diff /  c) * @@grid_magnitude)
                y_mov = - ( (y_diff /  c) * @@grid_magnitude)

                if c < @@grid_magnitude
                    x_mov = 0
                    y_mov = 0
                    # We have blocked everything along the path, move to the next waypoint
                    waypoint = spec_waypoints[i+=1]
                else
                    position[0] += x_mov
                    position[1] += y_mov
                end
                position_grid_x = ( position[0].to_i / 50 ) * 50
                position_grid_y = ( position[1].to_i / 50 ) * 50
                position_grid = [position_grid_x, position_grid_y]
                @banned_positions[position_grid] = "Bug path"
            end
        end
    end

    # A level will, by default, provide a random waypoint path from its array of waypoint paths.
    # Override this method to give your level special behaviour, for example, an order in which to expect the bugs. 
    def get_wave_waypoints
	waypoint_i = rand(@waypoints_array.size)		     # Randomly choose a waypoint path from the available paths.
 	return @waypoints_array[waypoint_i]
    end
end
