class_name CardingState
extends HeroState

@export var swap_state: HeroState


func enter_state() -> void:
	if hero.game_manager:
		hero.game_manager.level.disable_all_tower_frames()
	hero.left_hand_model.visible = true
	hero.gauntlet_model.visible = true
	hero.set_card_elements_visibility(true)
	hero.carding_tool.enabled = true
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_method(anim, hero.anim_tree.get("parameters/Blend3/blend_amount"), 0.0, 0.5)
	tween.tween_method(anim2, hero.anim_tree2.get("parameters/Blend2/blend_amount"), 0.0, 0.5)


func anim(x: float) -> void:
	hero.anim_tree.set("parameters/Blend3/blend_amount", x)


func anim2(x: float) -> void:
	hero.anim_tree2.set("parameters/Blend2/blend_amount", x)


func exit_state() -> void:
	hero.set_card_elements_visibility(false)
	hero.left_hand.visible = false
	hero.carding_tool.enabled = false


func process_state(_delta: float) -> void:
	hero.check_world_button()
	if Input.is_action_just_pressed("Interact"):
		hero.carding_tool.interact()
	if Input.is_action_just_pressed("Primary Fire"):
		hero.equip_weapon(0)
	if Input.is_action_just_pressed("Secondary Fire"):
		hero.equip_weapon(1)
	if Input.is_action_just_pressed("Select Next Card") and hero.hand.size > 1:
		hero.increment_selected()
		hero.swap_card_audio.play()
	if Input.is_action_just_pressed("Select Previous Card") and hero.hand.size > 1:
		hero.decrement_selected()
		hero.swap_card_audio.play()
	if Input.is_action_just_pressed("Equip 1"):
		swap_to_slot(1)
	if Input.is_action_just_pressed("Equip 2"):
		swap_to_slot(2)
	if Input.is_action_just_pressed("Equip 3"):
		swap_to_slot(3)
	if Input.is_action_just_pressed("Equip 4"):
		swap_to_slot(4)
	if Input.is_action_just_pressed("Equip 5"):
		swap_to_slot(5)
	if Input.is_action_just_pressed("Equip 6"):
		swap_to_slot(6)
	if Input.is_action_just_pressed("Equip 7"):
		swap_to_slot(7)
	if Input.is_action_just_pressed("Equip 8"):
		swap_to_slot(8)
	if Input.is_action_just_pressed("Equip 9"):
		swap_to_slot(9)
	if Input.is_action_just_pressed("Equip 10"):
		swap_to_slot(10)
	if Input.is_action_just_pressed("Swap Weapons"):
		state_changed.emit(swap_state)
	if Input.is_action_just_pressed("Ready"):
		if hero.ready_state:
			hero.unready_self()
		else:
			hero.ready_self()
	if !hero.game_manager and Input.is_action_just_pressed("Ready"):
		hero.enter_fighting_state()


func swap_to_slot(num: int) -> void:
	if hero.hand.size >= num:
		hero.hand_selected_index = num - 1
		hero.swap_card_audio.play()
		hero.hud.hot_wheel.update_cassettes(hero.get_wheel_cards())
