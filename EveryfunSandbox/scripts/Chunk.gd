extends Node3D

class_name Chunk

var array = []
var chunkPosition
var chunkUpdated = false

func updateMesh():
	var meshlist = $meshlist
	if meshlist:
		meshlist.free()
		
	meshlist = Node3D.new()
	meshlist.position = chunkPosition
	meshlist.name = "meshlist"
	add_child(meshlist)
	
	var usesCount = {}
	var currentIndex = {}
	for ix in range(chunkManager.chunkSize):
		for iy in range(chunkManager.chunkSize):
			for iz in range(chunkManager.chunkSize):
				var position = Vector3(ix, iy, iz)
				var blockname = array[chunkManager.getChunkArrayPosition(position)]
				if blockname:
					if blockname in usesCount:
						usesCount[blockname] += 1
					else:
						usesCount[blockname] = 1
						currentIndex[blockname] = 0
	
	for ix in range(chunkManager.chunkSize):
		for iy in range(chunkManager.chunkSize):
			for iz in range(chunkManager.chunkSize):
				var position = Vector3(ix, iy, iz)
				var blockname = array[chunkManager.getChunkArrayPosition(position)]
				
				if blockname:
					var multiMeshInstance:MultiMeshInstance3D = meshlist.get_node(blockname)
					if not multiMeshInstance:
						var _mesh = blockManager.getMeshAndMaterial(blockManager.getBlockscript(blockname))
						
						var multiMesh = MultiMesh.new()
						multiMesh.transform_format = MultiMesh.TRANSFORM_3D
						multiMesh.mesh = _mesh[0]
						multiMesh.instance_count = usesCount[blockname]
							
						multiMeshInstance = MultiMeshInstance3D.new()
						multiMeshInstance.name = blockname
						multiMeshInstance.material_override = _mesh[1]
						multiMeshInstance.multimesh = multiMesh
						meshlist.add_child(multiMeshInstance)
				
					var transform = Transform3D()
					transform.origin = position
					multiMeshInstance.multimesh.set_instance_transform(currentIndex[blockname], transform)
					currentIndex[blockname] += 1
	
