class_name ShieldUI
extends Control

@export var cells: Array[TextureRect] = []
@export var hit_glow: TextureRect
@export var fade_timer: Timer

const CELL_HEALTH: int = 9

var fading_enabled: bool = true
var health: int = 144
var current_cell_health: int = CELL_HEALTH
var fade_tween: Tween
var cell_tweens: Array[Tween] = []


func _ready() -> void:
	for x: int in cells.size():
		cell_tweens.append(null)
	fade_timer.start()


func take_damage(damage: int) -> void:
	if fade_tween:
		fade_tween.kill()
		fade_tween = null
	modulate = Color.WHITE
	var damage_to_deal_with: int = min(damage, current_cell_health)
	var remaining_damage: int = damage - damage_to_deal_with
	var current_cell: int = ceili(float(health) / CELL_HEALTH)
	health -= damage_to_deal_with
	current_cell_health -= damage_to_deal_with
	var cell_level: int = health % 9
	if remaining_damage > 0: ## This cell should be empty because the damage overran the cell
		if cell_tweens[current_cell - 1]:
			cell_tweens[current_cell - 1].kill()
		cell_level = 3
		current_cell_health = CELL_HEALTH
		change_cell_color(current_cell - 1, cell_level)
		take_damage(remaining_damage)
		return
	elif current_cell_health == 0:
		cell_level = 3
		current_cell_health = CELL_HEALTH
	elif cell_level > 0 and cell_level <= 3: ## This cell should be low health
		cell_level = 2
	elif cell_level > 3 and cell_level <= 6: ## This cell should be half health
		cell_level = 1
	else: ## This cell should be full health
		cell_level = 0
	hit_glow.texture.region.position.x = 66.0 * (16 - current_cell)
	if cell_tweens[current_cell - 1]:
		cell_tweens[current_cell - 1].kill()
	cell_tweens[current_cell - 1] = create_tween()
	cell_tweens[current_cell - 1].tween_callback(func() -> void: hit_glow.visible = true)
	cell_tweens[current_cell - 1].tween_interval(0.07)
	cell_tweens[current_cell - 1].tween_callback(func() -> void: hit_glow.visible = false)
	cell_tweens[current_cell - 1].tween_interval(0.07)
	cell_tweens[current_cell - 1].tween_callback(func() -> void: hit_glow.visible = true)
	cell_tweens[current_cell - 1].tween_callback(change_cell_color.bind(current_cell - 1, cell_level))
	cell_tweens[current_cell - 1].tween_interval(0.07)
	cell_tweens[current_cell - 1].tween_callback(func() -> void: hit_glow.visible = false)
	fade_timer.start()


func change_cell_color(cell: int, color: int) -> void:
	var cell_to_change: int = 15 - cell
	if cell_to_change >= 0 and cell_to_change < cells.size():
		cells[15 - cell].texture.region.position.x = 66.0 * color


func fade_out() -> void:
	if fade_tween:
		fade_tween.kill()
	if fading_enabled:
		fade_tween = create_tween()
		fade_tween.tween_property(self, "modulate", Color8(255, 255, 255, 0), 1.0)
