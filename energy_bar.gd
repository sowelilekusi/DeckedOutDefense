class_name EnergyBar extends Control

@export var cell_icon_tex: Texture
@export var bar_overlay: TextureRect
@export var progress_bar: ProgressBar
var cell_icons: Array[TextureRect]
var energy: float = 0
var max_energy: float = 0 : 
	get():
		return max_energy
	set(value):
		max_energy = value
		energy = max_energy


#TODO: we can just create all 12 of these not even in a script, just create them
#and use the bar overlay to hide the unused ones, we just need to change the algorithm
#for setting the used ones invisible to account for the ones that are there but hidden
func create_discrete_icons(new_energy: int) -> void:
	progress_bar.visible = false
	for icon: TextureRect in cell_icons:
		icon.queue_free()
	if new_energy < 12:
		bar_overlay.visible = true
		bar_overlay.texture.region = Rect2(159.0 * (-new_energy + 11), 0.0, 159.0, 422.0)
	else:
		bar_overlay.visible = false
	cell_icons = []
	energy = new_energy
	for x: int in energy:
		var new_icon: TextureRect = TextureRect.new()
		new_icon.texture = cell_icon_tex
		#new_icon.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		#new_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		new_icon.size = Vector2(42.0, 35.0)
		new_icon.position = Vector2(-70, -70 + (-27 * x))
		cell_icons.append(new_icon)
		add_child(new_icon)


func enable_progress_bar() -> void:
	for icon: TextureRect in cell_icons:
		icon.queue_free()
	cell_icons = []
	bar_overlay.visible = false
	progress_bar.visible = true
	progress_bar.max_value = max_energy
	progress_bar.value = max_energy


func blank() -> void:
	progress_bar.visible = false
	bar_overlay.visible = false
	for icon: TextureRect in cell_icons:
		icon.queue_free()
	cell_icons = []


func use_energy(energy_used: float, energy_type: Data.EnergyType = Data.EnergyType.DISCRETE) -> void:
	if energy <= 0:
		return
	if energy_type == Data.EnergyType.DISCRETE:
		for x: int in int(energy_used):
			energy -= 1
			cell_icons[energy].visible = false
	else:
		energy -= energy_used
		progress_bar.value = energy


func gain_energy(energy_gained: float, energy_type: Data.EnergyType = Data.EnergyType.DISCRETE) -> void:
	if energy >= max_energy:
		return
	if energy_type == Data.EnergyType.DISCRETE:
		for x: int in int(energy_gained):
			cell_icons[energy].visible = true
			energy += 1
	else:
		energy += energy_gained
		progress_bar.value = energy
