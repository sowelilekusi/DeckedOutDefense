class_name AscensionWeapon extends Weapon


func shoot() -> void:
	super.shoot()
	hero.movement.apply_ragdoll(-hero.camera.global_basis.z * 14.0)
