class_name LevelMagec
extends Node3D

@export var level_scene: PackedScene
@export var widget_scene: PackedScene
@export var level_parent: Node3D
@export var widget_parent: Node3D
@export var camera: Camera3D

@export var transition: float :
	get():
		return transition
	set(value):
		transition = value
		$CanvasLayer/TextureRect2.modulate = Color(1, 1, 1, 1.0 - value)


var wireframe: WireFrame
var level_config: LevelConfig = load("res://Levels/Level2/specs.tres")


func _ready() -> void:
	create_widget(null)
	camera.make_current()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact"):
		$AnimationPlayer.play("level_select_camera")


func create_widget(mesh: Mesh) -> void:
	wireframe = widget_scene.instantiate() as WireFrame
	widget_parent.add_child(wireframe)
	var flow_field_data: FlowFieldData = FlowFieldTool.load_flow_field_from_disc(level_config.zone.flow_field_data_path)
	for node: FlowNodeData in flow_field_data.nodes:
		if level_config.points_blocked.has(node.node_id):
			wireframe.spawn_blocker(node.position)
