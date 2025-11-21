extends Node


# Level transitions
signal level_completed
signal game_over
signal obj_complete
signal toggle_game_ui
signal toggle_level_processing

#Level loading
signal load_levels_by_set
signal load_levels_indiv
signal enter_room
signal load_level_map
signal load_first_level
signal load_objectives
signal load_menu_scene


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
signal allied_enemy_hit
signal boss_died

#Camera Effects
signal camera_shake

#Spawn control
signal activate
signal deactivate
signal spawn_update
signal boss_spawn
#spawn_update(Enemy type, true=add false=remove)\

signal parried
signal staggered
signal enemy_parried

#Handle Player Data
signal set_player_data
signal get_player_data

#Lockon
signal lockon_to
signal unlock_from

#Enemy Reactions
signal parry_failed
signal parry_success

#Cutscenes and QTEs
signal start_cutscene
signal play_cutscene_segment
signal queue_cutscene
signal end_cutsene
signal start_qte
signal qte_choice
signal qte_end


#Doors and switches
signal unlock_door
signal open_door
signal door_opened

#Inventory update
signal add_inventory
signal remove_inventory
signal update_inventory

#Global Generic Flag
signal global_flag_trigger
