extends StatusEffect
class_name StatusSticky


func on_attached():
	super.on_attached()
	affected.movement_speed = affected.stats.movement_speed * (1.0 - stats.potency)


func on_removed():
	super.on_removed()
	var siblings = get_parent().get_children()
	var stickies = 0
	for node in siblings:
		if node is StatusSticky:
			stickies += 1
	if stickies == 1:
		affected.movement_speed = affected.stats.movement_speed
