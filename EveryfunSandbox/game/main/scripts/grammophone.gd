extends baseblock

var sinDestortion = 0.5

var defaultStorageData = {
	rpm = 78.26
}

var eff_bg = preload("res://game/main/sounds/grammophone/background.mp3")
var eff_border = preload("res://game/main/sounds/grammophone/disk_border.mp3")

var audioPlayer: AudioStreamPlayer3D
var audioPlayerEffect: AudioStreamPlayer3D
var rotationCount = 0

func __updateSound():
	audioPlayer.pitch_scale = (storageData.rpm + (sin(rotationCount * PI * 2) * sinDestortion)) / defaultStorageData.rpm

func __play(path):
	audioPlayerEffect.stream = eff_bg
	audioPlayerEffect.play()
	
	audioPlayer.stream = game.loadResource(path)
	audioPlayer.play()
	
func __stop():
	audioPlayer.stop()
	audioPlayerEffect.stop()
	
func __initAudioPlayer(audioPlayer):
	game.initAudioStream(audioPlayer)
	audioPlayer.emission_angle_enabled = true
	audioPlayer.emission_angle_degrees = 45
	audioPlayer.emission_angle_filter_attenuation_db = -30

func __disk_end():
	audioPlayerEffect.stream = eff_border


func _ready():
	var node = Node3D.new()
	node.rotation_degrees = Vector3(0, -90, 0)
	
	audioPlayer = AudioStreamPlayer3D.new()
	audioPlayer.bus = "Grammophone"
	__initAudioPlayer(audioPlayer)
	audioPlayer.connect("finished", __disk_end)
	
	audioPlayerEffect = AudioStreamPlayer3D.new()
	audioPlayerEffect.bus = "Effects"
	__initAudioPlayer(audioPlayerEffect)
	
	__updateSound()

	node.add_child(audioPlayer)
	add_child(node)

func _process(delta):
	rotationCount += (delta * storageData.rpm) / 60
	__updateSound()

func _requestDefaultStorageData():
	return defaultStorageData

func _use():
	game.requestFile([consts.extfilter_audio], __play)
