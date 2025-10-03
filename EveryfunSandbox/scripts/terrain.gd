extends VoxelLodTerrain

var world_generator = preload("res://generators/world.gd")
var voxel_tool
var saveTracker
var saveGameMessage
var saveWait = false

func init(terrainPath):
	var mesher = VoxelMesherBlocky.new()
	mesher.library = game.blockLibrary
	
	var stream = VoxelStreamSQLite.new()
	stream.database_path = terrainPath
	
	self.mesher = mesher
	self.generator = world_generator.new()
	self.view_distance = 128
	self.lod_distance = 64
	self.stream = stream
	
	voxel_tool = get_voxel_tool()
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE

func _process(delta):
	if saveTracker && saveTracker.is_complete():
		saveGameMessage.queue_free()
		saveTracker = null
	
	if saveWait && not saveTracker:
		save()

func save():
	if saveTracker:
		saveWait = true
		return
	
	saveTracker = save_modified_blocks()
	saveGameMessage = game.gameMessage("saving terrain...", true, true)
