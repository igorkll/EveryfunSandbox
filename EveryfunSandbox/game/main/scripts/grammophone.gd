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
	var pitch = (storageData.rpm + (sin(rotationCount * PI * 2) * sinDestortion)) / defaultStorageData.rpm
	audioPlayer.pitch_scale = pitch
	audioPlayerEffect.pitch_scale = pitch

func __play(path):
	audioPlayerEffect.stream = eff_bg
	audioPlayerEffect.volume_db = 5
	audioPlayerEffect.play()
	
	audioPlayer.stream = game.loadResource(path)
	audioPlayer.play()
	
func __stop():
	audioPlayer.stop()
	audioPlayerEffect.stop()

func __disk_end():
	audioPlayerEffect.stream = eff_border
	audioPlayerEffect.volume_db = 0
	audioPlayerEffect.play()
	
func __effect_end():
	audioPlayerEffect.play()


func _ready():
	var node = Node3D.new()
	node.rotation_degrees = Vector3(0, -90, 0)
	
	audioPlayer = AudioStreamPlayer3D.new()
	audioPlayer.bus = "Grammophone"
	game.initAudioStream(audioPlayer)
	audioPlayer.emission_angle_enabled = true
	audioPlayer.emission_angle_degrees = 45
	audioPlayer.emission_angle_filter_attenuation_db = -30
	audioPlayer.connect("finished", __disk_end)
	node.add_child(audioPlayer)
	
	audioPlayerEffect = AudioStreamPlayer3D.new()
	audioPlayerEffect.bus = "Effects"
	game.initAudioStream(audioPlayerEffect)
	audioPlayerEffect.connect("finished", __effect_end)
	node.add_child(audioPlayerEffect)
	
	__updateSound()

	add_child(node)

func _process(delta):
	rotationCount += (delta * storageData.rpm) / 60
	__updateSound()

func _requestDefaultStorageData():
	return defaultStorageData

func _use():
	game.requestFile([consts.extfilter_audio], __play)
