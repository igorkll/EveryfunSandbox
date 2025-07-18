extends Node

static func spawn(world, position, dynamic, blockscript):
	var body
	if dynamic:
		body = RigidBody3D.new()
	else:
		body = StaticBody3D.new()
	
	body.position = position
	body.set_script(blockscript)
	
	var box_collision = CollisionShape3D.new()
	box_collision.shape = BoxShape3D.new()
	body.add_child(box_collision)

	if "mesh" in blockscript:
		var mesh = blockscript.mesh

		var material
		if "shader" in blockscript:
			material = ShaderMaterial.new()
			material.shader = blockscript.shader
		else:
			material = StandardMaterial3D.new()
			if "texture" in blockscript:
				material.albedo_texture = blockscript.texture
			
		body.__material = material
		
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = mesh
		mesh_instance.material_override = material
		body.add_child(mesh_instance)

	world.add_child(body)
	return body

static func destroy(blockobject):
	blockobject.queue_free()
	
static func interact(blockobject):
	if "__interact" in blockobject:
		blockobject.__interact()

static func isBlock(blockobject):
	return blockobject is RigidBody3D || blockobject is StaticBody3D
	
