@tool
extends MeshInstance3D
class_name DebugMesh


func _ready():
	var mat = StandardMaterial3D.new()
	mesh = ImmediateMesh.new()
	mat.no_depth_test = true
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	set_material_override(mat)


func clear():
	mesh.clear_surfaces()


func draw_line(begin_pos: Vector3, end_pos: Vector3, color: Color = Color.RED) -> void:
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(begin_pos)
	mesh.surface_add_vertex(end_pos)
	mesh.surface_end()


func draw_sphere(center: Vector3, radius: float = 1.0, color: Color = Color.RED) -> void:
	var step: int = 30
	var sppi: float = 2 * PI / step
	var axes = [
		[Vector3.UP, Vector3.RIGHT],
		[Vector3.RIGHT, Vector3.FORWARD],
		[Vector3.FORWARD, Vector3.UP]
	]
	for axis in axes:
		mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		mesh.surface_set_color(color)
		for i in range(step + 1):
			mesh.surface_add_vertex(center + (axis[0] * radius)
				.rotated(axis[1], sppi * (i % step)))
		mesh.surface_end()
