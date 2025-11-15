class_name EnemyRow
extends VBoxContainer

signal enemy_clicked(enemy: Enemy)

@export var wave_label: Label
@export var enemy_hbox: HBoxContainer

var last_pressed_button: Button


func set_wave(wave: int) -> void:
	wave_label.text = tr("LABEL_WAVE").format({Wave_Number = str(wave)})


func add_enemy_tag(enemy: Enemy, num: int) -> void:
	var container: MarginContainer = MarginContainer.new()
	enemy_hbox.add_child(container)
	var enemy_button: Button = Button.new()
	enemy_button.icon = enemy.icon
	enemy_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	enemy_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_button.custom_minimum_size = Vector2(32, 32)
	enemy_button.pressed.connect(on_button_pressed.bind(enemy))
	container.add_child(enemy_button)
	var amount_label: Label = Label.new()
	amount_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	amount_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	amount_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	amount_label.text = str(num)
	container.add_child(amount_label)


func on_button_pressed(enemy: Enemy) -> void:
	enemy_clicked.emit(enemy)
