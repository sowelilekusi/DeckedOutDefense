class_name MainMenuLevelSelector extends PanelContainer

signal level_selected(specs: LevelSpecs, side_chosen: int)

var side: int = 0

@export var levels: Array[LevelSpecs] = []

func _on_button_pressed() -> void:
	side = 0
	$VBoxContainer/Label.text = tr("LABEL_CAMPAIGN_DESC")


func _on_button_2_pressed() -> void:
	side = 1
	$VBoxContainer/Label.text = tr("LABEL_ENDLESS_DESC")


func _ready() -> void:
	var i: int = 0
	for level: LevelSpecs in levels:
		i += 1
		var button: Button = Button.new()
		button.text = "Level " + str(i)
		$VBoxContainer.add_child(button)
		button.pressed.connect(start_level.bind(i - 1))


func start_level(level: int) -> void:
	level_selected.emit(levels[level], side)
