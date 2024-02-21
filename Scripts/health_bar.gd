class_name HealthBar extends TextureProgressBar

@export var health_bar_gradient: Gradient

@onready var prev_bar: TextureProgressBar = $PreviousHealthBar


func setup(health: float) -> void:
	max_value = health
	value = health
	prev_bar.max_value = health
	prev_bar.value = health


func on_health_changed(health: float) -> void:
	set_visible(true)
	var health_went_down: bool = true if health < value else false
	value = health
	tint_progress = health_bar_gradient.sample(value / max_value)
	if health_went_down:
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_QUINT)
		tween.tween_interval(0.3)
		tween.tween_property(prev_bar, "value", value, 0.7)
	else:
		prev_bar.value = value
