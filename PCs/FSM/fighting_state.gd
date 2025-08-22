class_name FightingState
extends HeroState


func enter_state() -> void:
	hero.hud.set_currencies_visible(false)
	hero.left_hand_model.visible = false
	if hero.weapons[hero.equipped_weapon]:
		hero.hud.set_energy_visible(true)
	var offhand_weapon: Weapon = hero.weapons[0] if hero.equipped_weapon == 1 else hero.weapons[1]
	if offhand_weapon:
		offhand_weapon.current_energy = offhand_weapon.max_energy
	if (!hero.weapons[hero.equipped_weapon] and offhand_weapon) or (hero.weapons[0] and hero.equipped_weapon == 1):
		hero.swap_weapons()
	if hero.weapons[hero.equipped_weapon]:
		hero.weapons[hero.equipped_weapon].current_energy = hero.weapons[hero.equipped_weapon].max_energy
		#this had to be commented out coz the new energy bar thinks "energy changed" is "energy used"
		#weapons[equipped_weapon].energy_changed.emit(weapons[equipped_weapon].current_energy)
	if hero.game_manager.card_gameplay:
		for x: int in hero.hand.contents.size():
			hero.discard_pile.add(hero.hand.remove_at(hero.hand.contents.size() - 1))
	hero.weapon_swap_timer.start()
	hero.hud.energy_label.visible = false
	if !hero.weapons[hero.equipped_weapon] and !offhand_weapon:
		hero.gauntlet_model.visible = false
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(anim, hero.anim_tree.get("parameters/Blend3/blend_amount"), 1.0, 0.5)


func anim(x: float) -> void:
	hero.anim_tree.set("parameters/Blend3/blend_amount", x)


func exit_state() -> void:
	hero.hud.set_currencies_visible(true)
	if hero.weapons[hero.equipped_weapon]:
		hero.weapons[hero.equipped_weapon].release_trigger()
		hero.weapons[hero.equipped_weapon].release_second_trigger()
		hero.weapons[hero.equipped_weapon].visible = false
	hero.hud.set_energy_visible(false)
	hero.hud.grow_wave_start_label()
	#hero.hud.primary_duration.visible = true
	#hero.hud.secondary_duration.visible = true
	if hero.game_manager.card_gameplay:
		hero.hud.energy_label.visible = true


func process_state(_delta: float) -> void:
	if hero.weapons[hero.equipped_weapon] and hero.weapons_active:
		if Input.is_action_just_pressed("Primary Fire"):
			hero.weapons[hero.equipped_weapon].hold_trigger()
		if Input.is_action_just_released("Primary Fire"):
			hero.weapons[hero.equipped_weapon].release_trigger()
		if Input.is_action_pressed("Secondary Fire"):
			hero.weapons[hero.equipped_weapon].hold_second_trigger()
		if Input.is_action_just_released("Secondary Fire"):
			hero.weapons[hero.equipped_weapon].release_second_trigger()
		if Input.is_action_pressed("Primary Fire"):
			hero.movement.can_sprint = false
		if Input.is_action_pressed("Secondary Fire"):
			hero.movement.can_sprint = false
	if Input.is_action_just_pressed("Equip Primary Weapon"):
		if hero.equipped_weapon == 1 and hero.weapons[0]:
			hero.swap_weapons()
	if Input.is_action_just_pressed("Equip Secondary Weapon"):
		if hero.equipped_weapon == 0 and hero.weapons[1]:
			hero.swap_weapons()
	if Input.is_action_just_pressed("Swap Weapons"):
		if hero.weapons[0] and hero.weapons[1]:
			hero.swap_weapons()
