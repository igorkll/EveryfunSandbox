extends VoxelLodTerrain

var world_generator = preload("res://generators/world.gd")
var blockChildren = {}
var voxel_tool
var isMainTerrain = true

var _loadedTime = 0

func init(terrainPath):
	filesystem.makeDirectoryForFile(terrainPath)
	threaded_update_enabled = true
	# streaming_system = VoxelLodTerrain.STREAMING_SYSTEM_CLIPBOX
	
	var mesher = VoxelMesherBlocky.new()
	mesher.library = game.blockLibrary
	
	var stream = VoxelStreamSQLite.new()
	stream.database_path = terrainPath
	
	self.mesher = mesher
	self.generator = world_generator.new()
	# self.mesh_block_size = 32
	self.view_distance = 32
	self.lod_distance = 32
	self.stream = stream
	
	voxel_tool = get_voxel_tool()
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE

func _process(delta):
	_loadedTime += delta
	if _loadedTime > 5 and (game.view_distance != view_distance or game.lod_distance != lod_distance):
		view_distance = game.view_distance
		lod_distance = game.lod_distance
