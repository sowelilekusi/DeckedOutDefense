extends Tower
class_name HitscanTower


func shoot():
	super.shoot()
	if targeted_enemy and is_instance_valid(targeted_enemy) and targeted_enemy.alive:
		targeted_enemy.damage(damage)


@rpc("reliable")
func networked_shoot():
	super.networked_shoot()
