class_name Spring
extends Node3D

@export var hero: Hero
@export var hud: HUD

@export var hud_affect: float
@export var affect: Node3D

@export var AccelerationScale: float = 200.0
@export var MaxAcceleration: float = 0.3
@export var Rebound: float = 2.0
@export var Damping: float = 14.0

var previousVelocity: Vector3;
var AccumulatedDifferential: Vector3;
var AccumulatedDeflection: Vector3;


func _process(delta: float) -> void:
	var current_velocity: Vector3 = hero.velocity
	var acceleration: Vector3 = previousVelocity - current_velocity
	
	acceleration /= AccelerationScale;
	
	if (acceleration.length() > MaxAcceleration):
		acceleration = acceleration.normalized() * MaxAcceleration;

	AccumulatedDifferential += acceleration;
	AccumulatedDeflection += AccumulatedDifferential;
	AccumulatedDifferential -= AccumulatedDeflection * Rebound * delta;
	AccumulatedDeflection -= AccumulatedDeflection * Damping * delta;
	
	previousVelocity = current_velocity;
	
	position.y = AccumulatedDeflection.y
	if affect:
		affect.position.y = AccumulatedDeflection.y
		affect.position.x = AccumulatedDeflection.z
	if hud:
		hud.offset = Vector2(AccumulatedDeflection.x, AccumulatedDeflection.y) * hud_affect
