extends CharacterBody3D
class_name Hero

signal ready_state_changed(state)
signal spawned
signal died

@export var hero_class: HeroClass
@export var camera : Camera3D
@export var left_hand : Node3D
@export var right_hand : Node3D
@export var right_hand_animator : AnimationPlayer
@export var edit_tool : EditTool
@export var gauntlet_sprite : Sprite3D
@export var sprite : EightDirectionSprite3D
@export var interaction_raycast : RayCast3D
@export var inventory : Inventory
@export var weapon : Weapon
@export var card : CardInHand
@export var pause_menu_scene : PackedScene
@export var weapon_scene : PackedScene
@export var hud : HUD
@export var movement : PlayerMovement

var equipped_card : Card
var paused := false
var editing_mode := true
var profile: PlayerProfile
var ready_state := false :
	set(value):
		ready_state = value
		networked_set_ready_state.rpc(ready_state)
		ready_state_changed.emit(ready_state)
var currency := 0 : 
	set(value):
		currency = value
		hud.set_currency_count(value)
	get:
		return currency
@export var sprint_zoom_speed := 0.2


func set_zoom_factor(value):
	movement.zoom_factor = value


func _ready() -> void:
	if is_multiplayer_authority():
		right_hand_animator.play("weapon_sway")
		right_hand_animator.speed_scale = 0
		hud.set_visible(true)
		camera.make_current()
		sprite.queue_free()
	else:
		camera.set_visible(false)
	if weapon != null:
		weapon.set_raycast_origin(camera)
	inventory.contents.append_array(hero_class.deck)
	sprite.texture = hero_class.texture
	check_left_hand_valid()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
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
		if weapon != null and Input.is_action_just_pressed("Primary Fire"):
			weapon.hold_trigger()
		if weapon != null and Input.is_action_just_released("Primary Fire"):
			weapon.release_trigger()
		if weapon != null and Input.is_action_pressed("Secondary Fire"):
			weapon.hold_second_trigger()
		if weapon != null and Input.is_action_just_released("Secondary Fire"):
			weapon.release_second_trigger()
		if weapon != null and Input.is_action_pressed("Primary Fire"):
			movement.can_sprint = false
		if weapon != null and Input.is_action_pressed("Secondary Fire"):
			movement.can_sprint = false
	
	if movement.sprinting:
		movement.zoom_factor -= sprint_zoom_speed * delta
		if movement.zoom_factor <= 1.0 - movement.sprint_zoom_factor:
			movement.zoom_factor = 1.0 - movement.sprint_zoom_factor
	camera.fov = Data.preferences.hfov * (1.0 / movement.zoom_factor)
	
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
		ready_state = true
	if event.is_action_pressed("Pause"):
		var menu = pause_menu_scene.instantiate() as PauseMenu
		pause()
		menu.closed.connect(unpause)
		hud.add_child(menu)


func unpause():
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	movement.set_process(true)
	movement.set_physics_process(true)


func pause():
	paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	movement.set_process(false)
	movement.set_physics_process(false)


func enter_editing_mode(value):
	hud.set_wave_count(value + 1)
	editing_mode = true
	edit_tool.enabled = true
	check_left_hand_valid()
	if weapon != null:
		weapon.release_trigger()


func exit_editing_mode(value):
	hud.set_wave_count(value)
	edit_tool.enabled = false
	edit_tool.delete_tower_preview()
	left_hand.set_visible(false)
	editing_mode = false


func check_left_hand_valid():
	if !editing_mode:
		return
	if inventory.contents.size() == 0:
		left_hand.set_visible(false)
		#gauntlet.texture.region = Rect2(64, 0, 64, 64)
	else:
		left_hand.set_visible(true)
		#gauntlet.texture.region = Rect2(0, 0, 64, 64)
		card.set_card(inventory.selected_item)


func equip_weapon():
	if weapon != null:
		unequip_weapon()
		return
	if inventory.contents.size() > 0:
		equipped_card = inventory.remove()
		weapon = equipped_card.weapon.instantiate()
		right_hand.add_child(weapon)
		gauntlet_sprite.set_visible(false)
		weapon.set_raycast_origin(camera)
		weapon.set_hero(self)
		check_left_hand_valid()


func unequip_weapon():
	gauntlet_sprite.set_visible(true)
	weapon.queue_free()
	inventory.add(equipped_card)
	equipped_card = null
	check_left_hand_valid()


#MULTIPLAYER NETWORKED FUNCTIONS
@rpc("reliable")
func networked_set_ready_state(state: bool):
	ready_state = state
	ready_state_changed.emit(state)
