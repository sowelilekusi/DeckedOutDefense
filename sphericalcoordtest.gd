extends Node3D

var radius: float
var inclination: float
var azimuth: float


func _process(delta: float) -> void:
	var x: float = radius * sin(deg_to_rad(inclination)) * cos(deg_to_rad(azimuth))
	var y: float = radius * sin(deg_to_rad(inclination)) * sin(deg_to_rad(azimuth))
	var z: float = radius * cos(deg_to_rad(inclination))
	$CSGSphere3D2.position = Vector3(x, y, z)


func change_radius(value: float) -> void:
	radius = value
	$VBoxContainer/HBoxContainer/SpinBox.value = value
	$VBoxContainer/HBoxContainer/HSlider.value = value


func change_inclination(value: float) -> void:
	inclination = value
	$VBoxContainer/HBoxContainer2/SpinBox.value = value
	$VBoxContainer/HBoxContainer2/HSlider.value = value


func change_azimuth(value: float) -> void:
	azimuth = value
	$VBoxContainer/HBoxContainer3/SpinBox.value = value
	$VBoxContainer/HBoxContainer3/HSlider.value = value
