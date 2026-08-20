@tool
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
signal load_level_states

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
signal enemy_death
signal boss_died
signal prepare_next_boss

#Camera Effects
##(Strength, Fade Weight)
signal camera_shake

#Hitstop
##(time_scale : float, duration : float)
signal hit_stop(time_scale : float, duration : float)
##(time_scale_end: float, duration: float, _weight: float)
signal hit_stop_ease(time_scale_end: float, duration: float, _weight: float)

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

#Clash Signals
signal parried
signal staggered
signal enemy_parried
signal enemy_clash_react

#Handle Player Data
signal set_player_data
signal get_player_data
signal reset_player_data
signal update_ui_data

signal player_death

#Handle GUI Events
signal set_ammo_type
signal remove_ammo
signal reload_ammo

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

signal play_dialogue_top(_dialogue_string : String,\
 _speed : String,\
 _pause_on_finish : bool,\
 _character : String,\
 _portrait : String,\
 _name : String)
signal play_dialogue_bot(_dialogue_string : String,\
 _speed : String,\
 _pause_on_finish : bool,\
 _character : String,\
 _portrait : String,\
 _name : String)

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
signal dialogue_flag_trigger
