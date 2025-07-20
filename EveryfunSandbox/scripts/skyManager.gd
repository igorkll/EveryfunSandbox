extends Node

static var node_root
static var node_main: Node3D
static var node_worldEnv: WorldEnvironment
static var node_worldLight: DirectionalLight3D

static var dayColor = Color(1, 1, 1)
static var nightColor = Color(1, 0.7, 0)
static var lastTime = 0.5

func _ready():
	node_root = get_tree().root
	node_main = node_root.get_node("main")
	node_worldEnv = node_main.get_node("worldEnv")
	node_worldLight = node_worldEnv.get_node("worldLight")
	setTime(lastTime)

static func setTime(time):
	lastTime = time
	time = wrapf(time, 0, 1)
	var dayOffset = abs(0.5 - time) * 2
	var dayValue = 1 - dayOffset
	node_worldEnv.environment.background_energy_multiplier = dayValue
	node_worldLight.light_color = nightColor.lerp(dayColor, dayValue)
	node_worldLight.light_energy = dayValue

static func getTime():
	return lastTime
