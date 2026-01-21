extends baseblock

var defaultStorageData = {}

var musicSuppressor: MusicSuppressor
var audioPlayer: AudioStreamPlayer3D
var rotationCount = 0

func __play(path):
	musicSuppressor.enabled = true
	audioPlayer.stream = game.loadResource(path)
	audioPlayer.play()
	
func __stop():
	audioPlayer.stop()
	musicSuppressor.enabled = false
	
func __onFileSelected(path):
	if path:
		__play(path)

func __disk_end():
	musicSuppressor.enabled = false

func _ready():
	var node = Node3D.new()
	node.rotation_degrees = Vector3(0, -90, 0)
	
	musicSuppressor = MusicSuppressor.new()
	musicSuppressor.radius = 64
	node.add_child(musicSuppressor)
	
	audioPlayer = AudioStreamPlayer3D.new()
	audioPlayer.bus = "Speaker"
	game.initAudioStream(audioPlayer)
	audioPlayer.emission_angle_enabled = true
	audioPlayer.emission_angle_degrees = 45
	audioPlayer.emission_angle_filter_attenuation_db = -30
	audioPlayer.max_db = 3
	audioPlayer.connect("finished", __disk_end)
	node.add_child(audioPlayer)
	
	add_child(node)

func _process(delta):
	pass

func _requestDefaultStorageData():
	return defaultStorageData

func _use():
	game.requestFile([consts.extfilter_audio], __onFileSelected)
