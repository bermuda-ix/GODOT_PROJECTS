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
signal reload_level
signal reload_level_checkpoint

signal in_door_way


# Pausing
signal pause
signal unpause

#Score
signal inc_score
signal score_entry

#Enemy signals
signal activate_elite
signal activate_boss
signal deactivate_elite
signal deactivate_boss
signal activate_regular
signal deactivate_regular
signal allied_enemy_hit
signal boss_died
signal prepare_next_boss

#Camera Effects
signal camera_shake

#Spawn control
signal activate
signal deactivate
signal spawn_update
signal boss_spawn
#signal spawn_update(enemy_type, add : bool)

#Heat Signals
signal increase_heat_gauge
signal increase_heat_lvl
signal reset_heat
signal retrieve_heat_stats

signal parried
signal staggered
signal enemy_parried

#Handle Player Data
signal set_player_data
signal get_player_data
signal reset_player_data
signal player_death

#Checkpoints
signal checkpoint_reached
signal load_checkpoint

#Saving game
signal save_game
signal load_game
signal save_states
signal load_states

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

signal prepare_arena
signal activate_arena

#Doors and switches
signal unlock_door
signal open_door
signal door_opened

#Interactables
signal open_interact_menu
signal close_interact_menu

signal call_elevator

#Inventory update
signal add_inventory
signal remove_inventory
signal update_inventory

#Global Generic Flag
signal global_flag_trigger
