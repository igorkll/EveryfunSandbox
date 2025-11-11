extends VoxelTerrain

var world_generator = preload("res://scripts/generators/empty.gd")
var blockChildren = {}
var voxel_tool
var isMainTerrain = false
var deferredActions = []

var id: int
var storageData
var defaultStorageData = {
	blocksCount = 0
}

var unloaded = false
var loadedBlocks = {}

func _ready():
	self.connect("mesh_block_entered", updateBlock)
	self.connect("block_unloaded", unloadBlock)

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
	
func updateBlock(pos, blockId=null):
	if unloaded:
		return
	
	unloadBlock(pos)
	
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
		
func unloadBlock(pos):
	if unloaded:
		return
	
	var block = loadedBlocks.get(pos)
	if block:
		if block[0]:
			block[0].queue_free()
		loadedBlocks.erase(pos)

func _process(delta):
	if unloaded:
		return
	
	self.max_view_distance = game.view_distance
	terrainUtils.applyDeferredActions(self)
	
	if not saves.isInteractiveChunkLoaded(position):
		bodyUtils.unloadBody(self)
