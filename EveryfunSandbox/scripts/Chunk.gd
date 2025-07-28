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

	var thread = Thread.new()
	thread.start(_updateMesh_thread.bind(meshlist))

func _updateMesh_thread(meshlist):
	var currentIndex = {}
	var multiMeshInstances = {}
	for i in range(chunkManager.chunkSize * chunkManager.chunkSize * chunkManager.chunkSize):
		var blockname = array[i]
		
		if blockname:
			var position = Vector3(i % chunkManager.chunkSize, floor(i / chunkManager.chunkSize) % chunkManager.chunkSize, floor(i / chunkManager.chunkSize / chunkManager.chunkSize))
			var multiMeshInstance: MultiMeshInstance3D
			if multiMeshInstances.has(blockname):
				multiMeshInstance = multiMeshInstances[blockname]
				
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
				meshlist.call_deferred("add_child", multiMeshInstance)
				multiMeshInstances[blockname] = multiMeshInstance
		
			var transform = Transform3D()
			transform.origin = position
			if not currentIndex.has(blockname):
				currentIndex[blockname] = 0
			
			multiMeshInstance.multimesh.set_instance_transform(currentIndex[blockname], transform)
			currentIndex[blockname] += 1
