class_name BuildingState
extends HeroState

@export var swap_state: HeroState


func enter_state() -> void:
	hero.edit_tool.enabled = true
	hero.game_manager.level.enable_non_path_tower_frames()


func exit_state() -> void:
	hero.edit_tool.interact_key_held = false
	hero.edit_tool.enabled = false
	hero.game_manager.level.disable_all_tower_frames()


func process_state(_delta: float) -> void:
	hero.check_world_button()
	if Input.is_action_just_pressed("Primary Fire"):
		hero.edit_tool.interact_key_held = true
	if Input.is_action_just_released("Primary Fire"):
		hero.edit_tool.interact_key_held = false
	if Input.is_action_just_pressed("Swap Weapons"):
		state_changed.emit(swap_state)
	if Input.is_action_pressed("Ready"):
		if hero.ready_state:
			hero.unready_self()
		else:
			hero.ready_self()
