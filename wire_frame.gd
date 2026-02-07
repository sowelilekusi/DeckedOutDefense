class_name WireFrame extends Node3D

@export var level_mesh: CSGMesh3D
@export var blocker_mesh: CSGMesh3D

#var level_parent: Node3D
#var blocker_parent: Node3D

var blockers: Array[CSGMesh3D] = []


func spawn_level(mesh: Mesh) -> void:
	pass


func spawn_blocker(pos: Vector3) -> void:
	var new_blocker: CSGMesh3D = blocker_mesh.duplicate()
	new_blocker.position = pos
	blockers.append(new_blocker)
	add_child(new_blocker)
	new_blocker.visible = true
