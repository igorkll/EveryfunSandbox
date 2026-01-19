extends VoxelTerrain

var world_generator = preload("res://scripts/generators/empty.gd")
var blockChildren = {}
var voxel_tool
var isMainTerrain = false
var deferredActions = []

var id: int
var storageData
var defaultStorageData = {
	blocksCount = 0,
	blocksInfo = {}
}

var lifeTime = 0
var inited = false
var unloaded = false
var needUpdate = false
var freeze = true
var loadedBlocks = {}
var callCount

func init(bodyId: int):
	id = bodyId
	storageData = funcs.merge_dicts(storageData, defaultStorageData)
	
	var terrainPath = bodyUtils.getBodyTerrainPath(bodyId)
	
	var mesher = VoxelMesherBlocky.new()
	mesher.library = blockUtils.blockLibrary
	
	var stream = VoxelStreamSQLite.new()
	stream.database_path = terrainPath
	
	self.mesher = mesher
	self.generator = world_generator.new()
	self.mesh_block_size = consts.chunk_size
	self.max_view_distance = game.view_distance
	self.stream = stream
	self.generate_collisions = false
	
	voxel_tool = get_voxel_tool()
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE
	
	for blockPos in storageData.blocksInfo:
		updateBlock(blockPos, storageData.blocksInfo[blockPos])
		
	bodyUtils.updateBody(self)
	inited = true
	
func updateBlock(pos, blockId=null):
	if unloaded:
		return
	
	var block = loadedBlocks.get(pos)
	if block:
		if block[0]:
			block[0].queue_free()
		loadedBlocks.erase(pos)
		storageData.blocksInfo.erase(pos)
	
	if blockId == null:
		blockId = terrainUtils.getBlockId(self, pos)
	
	if blockId > 0:
		var collider = null
		
		var colliderShape = blockUtils.getBlockCollider(blockId)
		if colliderShape:
			collider = CollisionShape3D.new()
			var voxelItem = blockUtils.list_id2obj[blockId]
			if voxelItem.has("rotation"):
				collider.rotation_degrees = voxelItem.rotation.r
			collider.position = pos
			collider.shape = colliderShape
			get_parent().add_child(collider)
		
		loadedBlocks[pos] = [collider, blockId]
		storageData.blocksInfo[pos] = blockId
		
	needUpdate = true

func _process(delta):
	if unloaded || not inited:
		return
		
	lifeTime += delta
	
	if needUpdate:
		bodyUtils.updateBody(self)
		needUpdate = false
	
	self.max_view_distance = game.view_distance
	terrainUtils.applyDeferredActions(self)
	
	var body = bodyUtils.getBody(self)
	if not saves.isInteractiveChunkLoadedFull(body.position):
		bodyUtils.unloadBody(self)
		return
	
	if lifeTime >= 0.1:
		body.freeze = freeze
	else:
		body.freeze = true
