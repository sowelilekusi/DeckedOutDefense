class_name MainMenuLevelSelector extends PanelContainer

signal level_selected(specs: LevelConfig, side_chosen: int)

var side: int = 0

@export var levels: Array[LevelConfig] = []

func _on_button_pressed() -> void:
	side = 0
	$VBoxContainer/Label.text = tr("LABEL_CAMPAIGN_DESC")


func _on_button_2_pressed() -> void:
	side = 1
	$VBoxContainer/Label.text = tr("LABEL_ENDLESS_DESC")


func _ready() -> void:
	var i: int = 0
	for level: LevelConfig in levels:
		i += 1
		var button: Button = Button.new()
		button.text = "Level " + str(i)
		$VBoxContainer.add_child(button)
		button.pressed.connect(start_level.bind(i - 1))
		button.mouse_entered.connect(hover_config.bind(i - 1))


func hover_config(level: int) -> void:
	if !side:
		var high_score: int = 0
		if Data.save_data.level_high_scores.has(levels[level].display_title):
			high_score = Data.save_data.level_high_scores[levels[level].display_title]
	
		if high_score > 0:
			$VBoxContainer/HighScoreLabel.text = "Highest Wave: " + str(high_score)
		else:
			$VBoxContainer/HighScoreLabel.text = "Never attempted!"
	else:
		var high_score: int = 0
		if Data.save_data.endless_high_scores.has(levels[level].display_title):
			high_score = Data.save_data.endless_high_scores[levels[level].display_title]
	
		if high_score > 0:
			$VBoxContainer/HighScoreLabel.text = "Highest B-SIDE Wave: " + str(high_score)
		else:
			$VBoxContainer/HighScoreLabel.text = "Never attempted!"


func start_level(level: int) -> void:
	level_selected.emit(levels[level], side)
