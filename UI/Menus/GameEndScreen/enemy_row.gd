class_name EnemyRow
extends VBoxContainer

@export var wave_label: Label
@export var enemy_hbox: HBoxContainer


func set_wave(wave: int) -> void:
	wave_label.text = tr("LABEL_WAVE").format({Wave_Number = str(wave)})


func add_enemy_tag(enemy: Enemy, num: int) -> void:
	var container: MarginContainer = MarginContainer.new()
	enemy_hbox.add_child(container)
	var enemy_tex: TextureRect = TextureRect.new()
	enemy_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	enemy_tex.texture = enemy.icon
	enemy_tex.custom_minimum_size = Vector2(32, 32)
	enemy_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	container.add_child(enemy_tex)
	var amount_label: Label = Label.new()
	amount_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	amount_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	amount_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	amount_label.text = str(num)
	container.add_child(amount_label)
