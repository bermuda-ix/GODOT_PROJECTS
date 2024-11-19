extends Node


# Level transitions
signal level_completed
signal game_over
signal obj_complete

# Pausing
signal pause
signal unpause

#Score
signal inc_score

#Enemy signals
signal activate_elite
signal activate_boss
signal deactivate_elite
signal deactivate_boss
signal activate_regular
signal deactivate_regular

signal activate
signal deactivate
signal spawn_update
#spawn_update(Enemy type, true=add false=remove)

#Handle Player Data
signal set_player_data
signal get_player_data
