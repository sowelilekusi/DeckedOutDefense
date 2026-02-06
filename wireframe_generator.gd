@tool
extends EditorScenePostImport

const OUT_PATH: String = "res://wireframes/"

func _post_import(scene: Node) -> Object:
	var children: Array[Node] = scene.get_children()
	print('Updating meshes to wireframe ', scene.name)
	
	for child: Node in children:
		if not is_instance_of(child, MeshInstance3D):
			continue

		var mesh_in: ArrayMesh = child.mesh

		assert(mesh_in.surface_get_primitive_type(0) == Mesh.PRIMITIVE_TRIANGLES)
		var mesh_out := MeshUtils.unroll_vertices(mesh_in, [Mesh.ARRAY_VERTEX, Mesh.ARRAY_TEX_UV, Mesh.ARRAY_CUSTOM0])
		assert(mesh_out.surface_get_primitive_type(0) == Mesh.PRIMITIVE_TRIANGLES)
		
		var material := ShaderMaterial.new()
		material.shader = preload("res://shader.gdshader")
		mesh_out.surface_set_material(0, material)
		
		#child.mesh = mesh_out
		#child.set_surface_override_material(0, material)
		#print('Updated ', child)
		
		var filename_out := OUT_PATH + scene.name + ".res"
		#mesh_out.take_over_path(filename_out)
		ResourceSaver.save(mesh_out, filename_out)
		# doesn't seem to help
		#, ResourceSaver.SaverFlags.FLAG_CHANGE_PATH | ResourceSaver.SaverFlags.FLAG_REPLACE_SUBRESOURCE_PATHS)
		
		break # only export first mesh

	return scene # Return the modified root node when you're done.
