class_name FloatAndSpin
extends RayCast3D

@export_range(0.0, 3.0) var float_height: float = 1.5
@export_range(0.0, 2.0) var bounce_dist: float = 0.5
@export_range(0.0, 2.0) var bounce_speed: float = 0.4
@export_range(0.0, 4.0) var spin_speed: float = 0.5
@export var curve: Curve

var start_height: float = 0.0
var dest_height: float = 0.0
var t: float = 0.0


func _ready() -> void:
	start_height = position.y
	
	#raycast downwards and position the item at a set height above the ground that the raycast
	#presumably hits
	
	#Now I know what you're thinking: "if the item is placed on the ground in the editor anyway, we can put
	#the item at the correct height by simply adding the height to the existing y value that the item will have
	#anyway when the game starts" but what you're not considering is that for ease of placement the model will probably
	#always be given an offset from the root nodes position so as youre placing it in the editor its not clipping through
	#the ground, and some items might be given more or less of this vertical offset, if we do it at runtime by actually
	#checking where the ground is, you dont need to fuck around with this offset at the scene level, you just adjust
	#the script variable and the item can figure itself out, yeah its fancy but its also a nice creature comfort.
	if is_colliding():
		start_height = get_collision_point().y + (1 * float_height) - (bounce_dist / 2.0)
	dest_height  = start_height + (bounce_dist / 2.0)


func _process(delta: float) -> void:
	t += bounce_speed * delta
	position.y = start_height + (dest_height - start_height) * curve.sample(t)
	if t >= 1.0:
		t = 0.0
	rotation.y += spin_speed * delta
