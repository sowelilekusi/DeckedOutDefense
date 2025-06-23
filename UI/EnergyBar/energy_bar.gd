class_name EnergyBar
extends Control

@export var cell_icon_tex: Texture
@export var bar_overlay: TextureRect
@export var progress_bar: ProgressBar
@export var big_progress_bar: ProgressBar
@export var secondary_progress_bar: ProgressBar
@export var bg: TextureRect
var cell_icons: Array[TextureRect]
var energy: float = 0
var secondary_energy: float = 0 :
	get():
		return secondary_energy
	set(value):
		secondary_energy = value
		secondary_progress_bar.value = secondary_energy
var prev_energy_int: int = 0
var max_energy: float = 0 : 
	get():
		return max_energy
	set(value):
		max_energy = value
		energy = max_energy
var secondary_max_energy: float = 0:
	get():
		return secondary_max_energy
	set(value):
		secondary_max_energy = value
		secondary_energy = secondary_max_energy
		secondary_progress_bar.visible = true
		secondary_progress_bar.max_value = secondary_max_energy


#TODO: we can just create all 12 of these not even in a script, just create them
#and use the bar overlay to hide the unused ones, we just need to change the algorithm
#for setting the used ones invisible to account for the ones that are there but hidden
func create_discrete_icons(new_energy: int) -> void:
	bg.visible = true
	progress_bar.visible = true
	big_progress_bar.visible = false
	for icon: TextureRect in cell_icons:
		icon.queue_free()
	if new_energy < 12:
		bar_overlay.visible = true
		bar_overlay.texture.region = Rect2(117.0 * (-new_energy + 11), 0.0, 117.0, 442.0)
		#progress_bar.position = Vector2(-101.0, -430.0 + ((-new_energy + 12.0) * 27.0))
		#progress_bar.size = Vector2(60.0, 316.0 - ((-new_energy + 12.0) * 27.0))
	else:
		bar_overlay.visible = false
		#progress_bar.position = Vector2(-101.0, -430.0)
		#progress_bar.size = Vector2(60.0, 316.0)
	progress_bar.position = Vector2(-101.0, -430.0 + ((-new_energy + 12.0) * 27.0))
	progress_bar.size = Vector2(60.0, 316.0 - ((-new_energy + 12.0) * 27.0))
	cell_icons = []
	energy = new_energy
	for x: int in energy:
		var new_icon: TextureRect = TextureRect.new()
		new_icon.texture = cell_icon_tex
		#new_icon.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		#new_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		new_icon.size = Vector2(42.0, 35.0)
		new_icon.position = Vector2(-92, -150 + (-27 * x))
		cell_icons.append(new_icon)
		add_child(new_icon)
	progress_bar.max_value = max_energy
	progress_bar.value = max_energy


func enable_progress_bar() -> void:
	for icon: TextureRect in cell_icons:
		icon.queue_free()
	cell_icons = []
	progress_bar.visible = true
	big_progress_bar.visible = true
	bar_overlay.visible = false
	bg.visible = false
	progress_bar.max_value = max_energy
	progress_bar.value = max_energy
	big_progress_bar.max_value = max_energy
	big_progress_bar.value = max_energy


func blank() -> void:
	progress_bar.visible = false
	bar_overlay.visible = false
	for icon: TextureRect in cell_icons:
		icon.queue_free()
	cell_icons = []


func gain_secondary_energy(energy_gained: float, _energy_type: Data.EnergyType = Data.EnergyType.DISCRETE) -> void:
	if secondary_energy >= secondary_max_energy:
		return
	secondary_energy += energy_gained


func disable_secondary_energy() -> void:
	secondary_progress_bar.visible = false


func use_energy(energy_used: float, energy_type: Data.EnergyType = Data.EnergyType.DISCRETE) -> void:
	if energy <= 0:
		return
	if energy_type == Data.EnergyType.DISCRETE:
		for x: int in int(energy_used):
			energy -= 1
			cell_icons[energy].visible = false
		energy = floorf(energy)
	else:
		energy -= energy_used
	progress_bar.value = energy
	big_progress_bar.value = energy


func gain_energy(energy_gained: float, energy_type: Data.EnergyType = Data.EnergyType.DISCRETE) -> void:
	if energy >= max_energy:
		return
	energy += energy_gained
	progress_bar.value = energy
	big_progress_bar.value = energy
	if energy_type == Data.EnergyType.DISCRETE and int(energy) > prev_energy_int:
		cell_icons[int(energy) - 1].visible = true
	prev_energy_int = int(energy)
