extends baseblock

var sinDestortion = 0.5

var defaultStorageData = {
	rpm = 78.26
}

var audioPlayer
var rotationCount = 0

func __updateSound():
	audioPlayer.pitch_scale = (storageData.rpm + (sin(rotationCount * PI * 2) * sinDestortion)) / defaultStorageData.rpm

func _ready():
	var node = Node3D.new()
	node.rotation_degrees = Vector3(0, -90, 0)
	
	audioPlayer = AudioStreamPlayer3D.new()
	audioPlayer.bus = "Grammophone"
	audioPlayer.stream = preload("res://game/main/music/8.mp3")
	game.initAudioStream(audioPlayer)
	audioPlayer.emission_angle_enabled = true
	audioPlayer.emission_angle_degrees = 45
	audioPlayer.emission_angle_filter_attenuation_db = -30
	__updateSound()

	node.add_child(audioPlayer)
	add_child(node)
	audioPlayer.play()

func _process(delta):
	rotationCount += (delta * storageData.rpm) / 60
	__updateSound()

func _requestDefaultStorageData():
	return defaultStorageData
