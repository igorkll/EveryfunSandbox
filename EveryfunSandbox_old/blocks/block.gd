extends Node3D

class_name block

var __name
var __material
var __data
var __state
var __parents: Node3D
var __rigid_body: RigidBody3D

var ___alldata
var ___gamedata

var ___allstate
var ___gamestate

func ___after_spawn(node_main, chunk, body, dynamic):
	if dynamic:
		node_main.get_node("dynamicObjects").add_child(body)
	else:
		chunk.get_node("staticObjects").add_child(body)
