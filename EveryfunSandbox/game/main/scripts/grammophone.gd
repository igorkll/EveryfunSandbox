extends baseblock

var sinDestortion = 2

var defaultStorageData = {
	rpm = 78.26
}

var audioPlayer
var rotationCount = 0

func __updateSound():
	audioPlayer.pitch_scale = (storageData.rpm + (sin(rotationCount * PI * 2) * sinDestortion)) / defaultStorageData.rpm

func _ready():
	audioPlayer = AudioStreamPlayer3D.new()
	audioPlayer.bus = "Grammophone"
	audioPlayer.stream = preload("res://game/main/music/8.mp3")
	game.initAudioStream(audioPlayer)
	audioPlayer.volume_db = -20
	__updateSound()

	add_child(audioPlayer)
	audioPlayer.play()

func _process(delta):
	rotationCount += delta * storageData.rpm
	__updateSound()

func _requestDefaultStorageData():
	return defaultStorageData
