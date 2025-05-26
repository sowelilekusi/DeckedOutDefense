class_name EnemyMovement extends Node

@export var character: CharacterBody3D

var astar: AStarGraph3D
var distance_remaining: float = 0.0
