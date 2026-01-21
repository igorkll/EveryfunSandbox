extends VoxelLodTerrain

var world_generator = preload("res://scripts/generators/world.gd")
var blockChildren = {}
var voxel_tool
var isMainTerrain = true
var deferredActions = []

var _loadedTime = 0

func init(terrainPath):
	filesystem.makeDirectoryForFile(terrainPath)
	threaded_update_enabled = true
	# streaming_system = VoxelLodTerrain.STREAMING_SYSTEM_CLIPBOX
	
	var mesher = VoxelMesherBlocky.new()
	mesher.library = blockUtils.blockLibrary
	
	var stream = VoxelStreamSQLite.new()
	stream.database_path = terrainPath
	
	self.mesher = mesher
	self.generator = world_generator.new()
	self.mesh_block_size = consts.chunk_size
	self.lod_count = consts.lod_count
	self.view_distance = consts.start_loading_area
	self.lod_distance = consts.start_loading_area
	self.stream = stream
	self.cache_generated_blocks = true
	
	voxel_tool = get_voxel_tool()
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE

func _process(delta):
	_loadedTime += delta
	if _loadedTime > consts.minimal_area_load_time and (game.view_distance != view_distance or game.lod_distance != lod_distance):
		view_distance = game.view_distance
		lod_distance = game.lod_distance
	
	terrainUtils.applyDeferredActions(self)
