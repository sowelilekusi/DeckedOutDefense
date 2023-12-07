extends CharacterBody3D
class_name Hero

signal ready_state_changed(state)
signal spawned
signal died

@export var hero_class: HeroClass
@export var camera : Camera3D
@export var gun_camera : Camera3D
@export var left_hand_sprite : Sprite3D
@export var left_hand : Node3D
@export var right_hand : Node3D
@export var right_hand_animator : AnimationPlayer
@export var edit_tool : EditTool
@export var gauntlet_sprite : Sprite3D
@export var sprite : EightDirectionSprite3D
@export var hand_sprite : Sprite2D
@export var interaction_raycast : RayCast3D
@export var inventory : Inventory
@export var card : CardInHand
@export var gauntlet_card_1 : CardInHand
@export var gauntlet_card_2 : CardInHand
@export var pause_menu_scene : PackedScene
@export var hud : HUD
@export var movement : PlayerMovement
@export var sprint_zoom_speed := 0.2
@export var player_name_tag : Label
@export var weapon_swap_timer : Timer
@export var ears : AudioListener3D

var equipped_card
var offhand_card
var weapon : Weapon
var offhand_weapon : Weapon
var weapons_active = false
var paused := false
var editing_mode := true
var profile : PlayerProfile
var ready_state := false : 
	set(value):
		ready_state = value
		ready_state_changed.emit(value)
var currency := 0 : 
	set(value):
		currency = value
		hud.set_currency_count(value)
	get:
		return currency


func set_zoom_factor(value):
	movement.zoom_factor = value


func _ready() -> void:
	if is_multiplayer_authority():
		right_hand_animator.play("weapon_sway")
		right_hand_animator.speed_scale = 0
		camera.make_current()
		sprite.queue_free()
		hand_sprite.texture = hero_class.hand_texture
		player_name_tag.queue_free()
		ears.make_current()
	else:
		camera.set_visible(false)
		gun_camera.set_visible(false)
		hud.set_visible(false)
	if weapon != null:
		weapon.set_raycast_origin(camera)
	inventory.contents.append_array(hero_class.deck)
	sprite.texture.atlas = hero_class.texture
	check_left_hand_valid()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority() or paused:
		return
	if movement.input_vector == Vector2.ZERO:
		right_hand_animator.speed_scale = 0
	elif movement.sprinting:
		right_hand_animator.speed_scale = 1
	else:
		right_hand_animator.speed_scale = 0.6


func _process(delta: float) -> void:
	if !is_multiplayer_authority() or paused:
		return
	if !movement.sprinting:
		movement.zoom_factor += sprint_zoom_speed * 2.0 * delta
		if movement.zoom_factor > 1.0:
			movement.zoom_factor = 1.0
	
	if editing_mode:
		if interaction_raycast.is_colliding() and interaction_raycast.get_collider() is InteractButton:
			hud.set_hover_text(interaction_raycast.get_collider().hover_text)
		else:
			hud.unset_hover_text()
		
		if edit_tool.is_looking_at_tower_base:
			card.view_tower()
		else:
			card.view_weapon()
		if Input.is_action_just_pressed("Interact"):
			edit_tool.interact()
			if interaction_raycast.get_collider() is InteractButton:
				var button = interaction_raycast.get_collider() as InteractButton
				if currency >= button.press_cost:
					button.press()
					currency -= button.press_cost
			if interaction_raycast.get_collider() is ItemCard:
				inventory.add(interaction_raycast.get_collider().pick_up())
		if Input.is_action_just_pressed("Equip In Gauntlet"):
			equip_weapon()
		if Input.is_action_just_pressed("Secondary Fire"):
			swap_weapons()
		if Input.is_action_just_pressed("Select Next Card"):
			inventory.increment_selected()
		if Input.is_action_just_pressed("Select Previous Card"):
			inventory.decrement_selected()
		if Input.is_action_just_pressed("Primary Fire"):
			edit_tool.interact_key_held = true
		if Input.is_action_just_released("Primary Fire"):
			edit_tool.interact_key_held = false
		if weapon != null:
			weapon.release_trigger()
			weapon.release_second_trigger()
	else:
		if weapon and weapons_active:
			if Input.is_action_just_pressed("Primary Fire"):
				weapon.hold_trigger()
			if Input.is_action_just_released("Primary Fire"):
				weapon.release_trigger()
			if Input.is_action_pressed("Secondary Fire"):
				weapon.hold_second_trigger()
			if Input.is_action_just_released("Secondary Fire"):
				weapon.release_second_trigger()
			if Input.is_action_pressed("Primary Fire"):
				movement.can_sprint = false
			if Input.is_action_pressed("Secondary Fire"):
				movement.can_sprint = false
		if Input.is_action_just_pressed("Equip In Gauntlet"):
			if weapon and offhand_weapon:
				swap_weapons()
	
	if movement.sprinting:
		movement.zoom_factor -= sprint_zoom_speed * delta
		if movement.zoom_factor <= 1.0 - movement.sprint_zoom_factor:
			movement.zoom_factor = 1.0 - movement.sprint_zoom_factor
	camera.fov = Data.graphics.hfov * (1.0 / movement.zoom_factor)
	
	if Input.is_action_just_pressed("View Map"):
		hud.maximise_minimap(Game.level)
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_released("View Map"):
		hud.minimize_minimap(self)
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	check_left_hand_valid()


func _unhandled_input(event: InputEvent) -> void:
	if !is_multiplayer_authority() or paused:
		return
	if editing_mode and event.is_action_pressed("Ready"):
		edit_tool.interact_key_held = false
		if !ready_state:
			ready_state = true
			networked_set_ready_state.rpc(ready_state)
	if event.is_action_pressed("Pause"):
		var menu = pause_menu_scene.instantiate() as PauseMenu
		pause()
		menu.closed.connect(unpause)
		hud.add_child(menu)


func add_card(card: Card):
	inventory.add(card)


func unpause():
	paused = false
	movement.paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func pause():
	paused = true
	movement.paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func enter_editing_mode(value):
	gauntlet_sprite.set_visible(true)
	weapons_active = false
	hud.set_wave_count(value + 1)
	hud.set_energy_visible(false)
	hud.set_offhand_energy_visible(false)
	editing_mode = true
	edit_tool.enabled = true
	left_hand.set_visible(true)
	if weapon:
		weapon.release_trigger()
		weapon.set_visible(false)


func exit_editing_mode(value):
	gauntlet_sprite.set_visible(false)
	weapons_active = false
	hud.set_wave_count(value)
	if !weapon and offhand_weapon:
		swap_weapons()
	if weapon:
		hud.set_energy_visible(true)
		#weapon.set_visible(false)
		weapon.current_energy = weapon.max_energy
		weapon.energy_changed.emit(weapon.current_energy)
	if offhand_weapon:
		hud.set_offhand_energy_visible(true)
		offhand_weapon.current_energy = offhand_weapon.max_energy
		offhand_weapon.energy_changed.emit(offhand_weapon.current_energy)
	edit_tool.enabled = false
	edit_tool.delete_tower_preview()
	left_hand.set_visible(false)
	editing_mode = false
	weapon_swap_timer.start()


func check_left_hand_valid():
	if !editing_mode:
		return
	if inventory.contents.size() == 0:
		left_hand_sprite.set_visible(false)
		#gauntlet.texture.region = Rect2(64, 0, 64, 64)
	else:
		left_hand_sprite.set_visible(true)
		#gauntlet.texture.region = Rect2(0, 0, 64, 64)
		card.set_card(inventory.selected_item)


func equip_weapon():
	if weapon != null:
		unequip_weapon()
		return
	if inventory.contents.size() > 0:
		equipped_card = inventory.remove()
		networked_equip_weapon.rpc(Data.cards.find(equipped_card))
		weapon = equipped_card.weapon_scene.instantiate()
		weapon.energy_changed.connect(hud.set_weapon_energy)
		#weapon.name = "weapon"
		weapon.set_multiplayer_authority(multiplayer.get_unique_id())
		#gauntlet_sprite.set_visible(false)
		gauntlet_card_1.set_card(equipped_card)
		gauntlet_card_1.view_weapon()
		gauntlet_card_1.set_visible(true)
		weapon.set_hero(self)
		weapon.set_visible(false)
		right_hand.add_child(weapon)
		check_left_hand_valid()


func equip_in_offhand():
	if offhand_weapon != null:
		unequip_weapon()
		return
	if inventory.contents.size() > 0:
		offhand_card = inventory.remove()
		networked_equip_offhand_weapon.rpc(Data.cards.find(offhand_card))
		offhand_weapon = offhand_card.weapon_scene.instantiate()
		offhand_weapon.energy_changed.connect(hud.set_weapon_energy)
		#offhand_weapon.name = "weapon"
		offhand_weapon.set_multiplayer_authority(multiplayer.get_unique_id())
		#gauntlet_sprite.set_visible(false)
		gauntlet_card_2.set_card(offhand_card)
		gauntlet_card_2.view_weapon()
		gauntlet_card_2.set_visible(true)
		offhand_weapon.set_hero(self)
		offhand_weapon.set_visible(false)
		right_hand.add_child(offhand_weapon)
		check_left_hand_valid()


func swap_weapons():
	if !editing_mode:
		weapons_active = false
	var temp = offhand_weapon
	var temp_card = offhand_card
	if weapon:
		offhand_weapon = weapon
		offhand_card = equipped_card
		offhand_weapon.set_visible(false)
		offhand_weapon.energy_changed.disconnect(hud.set_weapon_energy)
		offhand_weapon.energy_changed.connect(hud.set_offhand_energy)
		offhand_weapon.energy_changed.emit(offhand_weapon.current_energy)
		offhand_weapon.release_trigger()
		offhand_weapon.release_second_trigger()
		gauntlet_card_2.set_card(offhand_card)
		gauntlet_card_2.view_weapon()
		gauntlet_card_2.set_visible(true)
	else:
		offhand_weapon = null
		offhand_card = null
		gauntlet_card_2.set_visible(false)
	if temp:
		weapon = temp
		equipped_card = temp_card
		weapon.energy_changed.disconnect(hud.set_offhand_energy)
		weapon.energy_changed.connect(hud.set_weapon_energy)
		weapon.energy_changed.emit(weapon.current_energy)
		weapon.release_trigger()
		weapon.release_second_trigger()
		gauntlet_card_1.set_card(equipped_card)
		gauntlet_card_1.view_weapon()
		gauntlet_card_1.set_visible(true)
	else:
		weapon = null
		equipped_card = null
		gauntlet_card_1.set_visible(false)
	if !editing_mode:
		weapon_swap_timer.start()


func _on_timer_timeout() -> void:
	weapons_active = true
	if weapon:
		weapon.set_visible(true)


func unequip_weapon():
	networked_unequip_weapon.rpc()
	gauntlet_card_1.set_visible(false)
	#gauntlet_sprite.set_visible(true)
	weapon.queue_free()
	weapon = null
	inventory.add(equipped_card)
	equipped_card = null
	check_left_hand_valid()


func unequip_offhand_weapon():
	networked_unequip_offhand_weapon.rpc()
	gauntlet_card_2.set_visible(false)
	#gauntlet_sprite.set_visible(true)
	offhand_weapon.queue_free()
	offhand_weapon = null
	inventory.add(offhand_card)
	offhand_card = null
	check_left_hand_valid()


#MULTIPLAYER NETWORKED FUNCTIONS
@rpc("reliable")
func networked_set_ready_state(state: bool):
	ready_state = state


@rpc("reliable")
func networked_equip_weapon(card_index):
	equipped_card = Data.cards[card_index]
	weapon = equipped_card.weapon_scene.instantiate()
	weapon.set_multiplayer_authority(multiplayer.get_remote_sender_id())
	#weapon.name = "weapon"
	weapon.set_hero(self)
	right_hand.add_child(weapon)


@rpc("reliable")
func networked_equip_offhand_weapon(card_index):
	equipped_card = Data.cards[card_index]
	offhand_weapon = equipped_card.weapon_scene.instantiate()
	offhand_weapon.set_multiplayer_authority(multiplayer.get_remote_sender_id())
	#weapon.name = "weapon"
	offhand_weapon.set_hero(self)
	right_hand.add_child(offhand_weapon)


@rpc("reliable")
func networked_unequip_weapon():
	weapon.queue_free()
	weapon = null
	inventory.add(equipped_card)
	equipped_card = null


@rpc("reliable")
func networked_unequip_offhand_weapon():
	offhand_weapon.queue_free()
	offhand_weapon = null
	inventory.add(equipped_card)
	offhand_card = null
