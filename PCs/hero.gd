class_name Hero extends CharacterBody3D

signal ready_state_changed(state: bool)
signal spawned
signal died

@export var hero_class: HeroClass
@export var camera: Camera3D
@export var gun_camera: Camera3D
@export var left_hand_sprite: Sprite3D
@export var card_sprites: Array[CardInHand]
@export var left_hand: Node3D
@export var right_hand: Node3D
@export var right_hand_animator: AnimationPlayer
@export var edit_tool: EditTool
@export var gauntlet_sprite: Sprite3D
@export var sprite: EightDirectionSprite3D
@export var hand_sprite: Sprite2D
@export var interaction_raycast: RayCast3D
@export var inventory: Inventory
@export var gauntlet_card_1: CardInHand
@export var gauntlet_card_2: CardInHand
@export var pause_menu_scene: PackedScene
@export var hud: HUD
@export var movement: PlayerMovement
@export var sprint_zoom_speed: float = 0.2
@export var player_name_tag: Label
@export var weapon_swap_timer: Timer
@export var ears: AudioListener3D

var inventory_selected_index: int = 0
var equipped_card: Card
var offhand_card: Card
var weapon: Weapon
var offhand_weapon: Weapon
var weapons_active: bool = false
var paused: bool = false
var editing_mode: bool = true
var profile: PlayerProfile
var ready_state: bool = false : 
	set(value):
		ready_state = value
		ready_state_changed.emit(value)
var currency: int = 0 : 
	set(value):
		currency = value
		hud.set_currency_count(value)
	get:
		return currency


func set_zoom_factor(value: float) -> void:
	movement.zoom_factor = value


func _ready() -> void:
	if is_multiplayer_authority():
		right_hand_animator.play("weapon_sway")
		right_hand_animator.speed_scale = 0
		ears.make_current()
		camera.make_current()
		sprite.queue_free()
		hand_sprite.texture = hero_class.hand_texture
		player_name_tag.queue_free()
		for card: Card in hero_class.deck:
			inventory.add(card)
	else:
		camera.set_visible(false)
		gun_camera.set_visible(false)
		hud.set_visible(false)
	if weapon != null:
		weapon.set_raycast_origin(camera)
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
			card_sprites[0].view_tower()
		else:
			card_sprites[0].view_weapon()
		if Input.is_action_just_pressed("Interact"):
			edit_tool.interact()
			if interaction_raycast.get_collider() is InteractButton:
				var button: InteractButton = interaction_raycast.get_collider() as InteractButton
				if currency >= button.press_cost:
					button.press(self)
					currency -= button.press_cost
			if interaction_raycast.get_collider() is ItemCard:
				add_card(interaction_raycast.get_collider().pick_up())
		if Input.is_action_just_pressed("Equip In Gauntlet"):
			equip_weapon()
		if Input.is_action_just_pressed("Secondary Fire"):
			swap_weapons()
		if Input.is_action_just_pressed("Select Next Card"):
			increment_selected()
			$AudioStreamPlayer.play()
		if Input.is_action_just_pressed("Select Previous Card"):
			decrement_selected()
			$AudioStreamPlayer.play()
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


func increment_selected() -> void:
	inventory_selected_index += 1
	if inventory_selected_index >= inventory.contents.keys().size():
		inventory_selected_index = 0


func decrement_selected() -> void:
	inventory_selected_index -= 1
	if inventory_selected_index < 0:
		inventory_selected_index = max(inventory.contents.keys().size() - 1, 0)


func _unhandled_input(event: InputEvent) -> void:
	if !is_multiplayer_authority() or paused:
		return
	if editing_mode and event.is_action_pressed("Ready"):
		edit_tool.interact_key_held = false
		if !ready_state:
			ready_state = true
			hud.shrink_wave_start_label()
			$AudioStreamPlayer.play()
			networked_set_ready_state.rpc(ready_state)
	if event.is_action_pressed("Pause"):
		var menu: PauseMenu = pause_menu_scene.instantiate() as PauseMenu
		pause()
		menu.closed.connect(unpause)
		hud.add_child(menu)


func add_card(new_card: Card) -> void:
	inventory.add(new_card)
	hud.pickup(new_card)


func unpause() -> void:
	paused = false
	movement.paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func pause() -> void:
	paused = true
	movement.paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func enter_editing_mode(value: int) -> void:
	gauntlet_sprite.set_visible(true)
	weapons_active = false
	hud.set_wave_count(value + 1)
	hud.set_energy_visible(false)
	hud.set_offhand_energy_visible(false)
	hud.grow_wave_start_label()
	editing_mode = true
	edit_tool.enabled = true
	left_hand.set_visible(true)
	if weapon:
		weapon.release_trigger()
		weapon.set_visible(false)


func exit_editing_mode(value: int) -> void:
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


func check_left_hand_valid() -> void:
	if !editing_mode:
		return
	if inventory.size == 0:
		left_hand_sprite.set_visible(false)
		#gauntlet.texture.region = Rect2(64, 0, 64, 64)
	else:
		left_hand_sprite.set_visible(true)
		#gauntlet.texture.region = Rect2(0, 0, 64, 64)
		var selected_card: Card = inventory.contents.keys()[inventory_selected_index]
		for index: int in card_sprites.size():
			if index < inventory.contents[selected_card]:
				card_sprites[index].set_visible(true)
				card_sprites[index].set_card(selected_card)
				#card_sprites[index].view_weapon()
			else:
				card_sprites[index].set_visible(false)


func equip_weapon() -> void:
	if weapon != null:
		unequip_weapon()
		return
	if inventory.size > 0:
		$AudioStreamPlayer.play()
		equipped_card = inventory.remove_at(inventory_selected_index)
		if !inventory.contents.has(equipped_card):
			decrement_selected()
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


func swap_weapons() -> void:
	if !editing_mode:
		weapons_active = false
	if weapon or offhand_weapon:
		$AudioStreamPlayer.play()
	var temp: Weapon = offhand_weapon
	var temp_card: Card = offhand_card
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
		$AudioStreamPlayer.play()
		weapon.set_visible(true)


func unequip_weapon() -> void:
	networked_unequip_weapon.rpc()
	gauntlet_card_1.set_visible(false)
	#gauntlet_sprite.set_visible(true)
	weapon.queue_free()
	weapon = null
	inventory.add(equipped_card)
	equipped_card = null
	$AudioStreamPlayer.play()
	check_left_hand_valid()


#MULTIPLAYER NETWORKED FUNCTIONS
@rpc("reliable")
func networked_set_ready_state(state: bool) -> void:
	ready_state = state


@rpc("reliable")
func networked_equip_weapon(card_index: int) -> void:
	equipped_card = Data.cards[card_index]
	weapon = equipped_card.weapon_scene.instantiate()
	weapon.set_multiplayer_authority(multiplayer.get_remote_sender_id())
	#weapon.name = "weapon"
	weapon.set_hero(self)
	right_hand.add_child(weapon)


@rpc("reliable")
func networked_unequip_weapon() -> void:
	weapon.queue_free()
	weapon = null
	inventory.add(equipped_card)
	equipped_card = null
