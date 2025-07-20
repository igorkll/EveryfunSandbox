extends Node3D

class_name Chunk

var array = []
var chunkPosition
var chunkUpdated = false
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
	
	var currentIndex = {}
	for ix in range(chunkManager.chunkSize):
		for iy in range(chunkManager.chunkSize):
			for iz in range(chunkManager.chunkSize):
				var position = Vector3(ix, iy, iz)
				var blockname = array[chunkManager.getChunkArrayPosition(position)]
				
				if blockname:
					var multiMeshInstance:MultiMeshInstance3D
					if meshlist.has_node(blockname):
						multiMeshInstance = meshlist.get_node(blockname)
						
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
					if not currentIndex.has(blockname):
						currentIndex[blockname] = 0
					
					multiMeshInstance.multimesh.set_instance_transform(currentIndex[blockname], transform)
					currentIndex[blockname] += 1
	
