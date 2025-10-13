extends Node

var settings_path = "user://settings.json"
var minimal_load_time = 1

var minimum_loading_radius_for_play = Vector3i(8, 8, 8)
var player_spawn_vertical_offset = 0.1

var base_mouse_sensitivity = 0.2
var base_joystick_camera_sensitivity = 200

var step_crouch_interval = 0.5
var step_interval = 0.4
var step_sprint_interval = 0.2

var player_mul_crouch = 0.5
var player_mul_sprint = 2

var default_scale_on_1080 = 1.5
