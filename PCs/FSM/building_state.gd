class_name BuildingState
extends HeroState

@export var swap_state: HeroState


func enter_state() -> void:
	if hero.game_manager:
		hero.game_manager.level.enable_non_path_tower_frames()
	hero.edit_tool.enabled = true
	hero.left_hand_model.visible = true
	hero.gauntlet_model.visible = true
	hero.cassette.visible = false
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_method(anim, hero.anim_tree.get("parameters/Blend3/blend_amount"), -1.0, 0.5)
	tween.tween_method(anim2, hero.anim_tree2.get("parameters/Blend2/blend_amount"), 1.0, 0.5)


func anim(x: float) -> void:
	hero.anim_tree.set("parameters/Blend3/blend_amount", x)


func anim2(x: float) -> void:
	hero.anim_tree2.set("parameters/Blend2/blend_amount", x)


func exit_state() -> void:
	hero.edit_tool.interact_key_held = false
	hero.edit_tool.enabled = false
	hero.cassette.visible = true
	if hero.game_manager:
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
