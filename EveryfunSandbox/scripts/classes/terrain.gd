extends VoxelLodTerrain

var world_generator = preload("res://scripts/generators/world.gd")
var blockChildren = {}
var voxel_tool
var isMainTerrain = true
var deferredActions = []

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
	self.view_distance = consts.start_loading_area
	self.lod_distance = consts.start_loading_area
	self.lod_count = 1
	self.stream = stream
	self.cache_generated_blocks = true
	
	voxel_tool = get_voxel_tool()
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE

func _process(delta):
	var _view_distance = game.view_distance
	var _lod_distance = game.lod_distance
	var _lod_count = game.lod_count
	if game.minimal_loading_area:
		_view_distance = consts.start_loading_area
		_lod_distance = consts.start_loading_area
		_lod_count = 1
	
	if _view_distance != view_distance or _lod_distance != lod_distance or _lod_count != lod_count:
		view_distance = _view_distance
		lod_distance = _lod_distance
		lod_count = _lod_count
	
	terrainUtils.applyDeferredActions(self)
