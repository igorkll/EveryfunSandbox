extends Node3D

class_name Chunk

var array = []
var chunkPosition
var usesCount = {}

func deltaUseCount(blockname, delta):
	if not usesCount.has(blockname):
		usesCount[blockname] = 0
	usesCount[blockname] += delta

func updateMesh():
	var meshlist
	if has_node("meshlist"):
		meshlist = $meshlist
		if meshlist:
			meshlist.free()
		
	meshlist = Node3D.new()
	meshlist.position = chunkPosition
	meshlist.name = "meshlist"
	add_child(meshlist)
	
	var combined_mesh = ArrayMesh.new()
	
	var combined_vertices = []
	var combined_normals = []
	var combined_uvs = []
	
	for ix in range(chunkManager.chunkSize):
		for iy in range(chunkManager.chunkSize):
			for iz in range(chunkManager.chunkSize):
				var position = Vector3(ix, iy, iz)
				var blockname = array[chunkManager.getChunkArrayPosition(position)]
				
				if blockname:
					var _mesh = blockManager.getMeshAndMaterial(blockManager.getBlockscript(blockname))
					
					var transform = Transform3D()
					transform.origin = position
				
					var arrays = _mesh[0].get_arrays()
					var t:ArrayMesh

					var vertices = arrays[Mesh.ARRAY_VERTEX]
					for vertex in vertices:
						combined_vertices.append(transform.xform(vertex))

					combined_normals += arrays[Mesh.ARRAY_NORMAL]
					combined_uvs += arrays[Mesh.ARRAY_TEX_UV]

	combined_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, [
		combined_vertices,
		combined_normals,
		combined_uvs
	])
