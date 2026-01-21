extends Node

var inputModalScene = preload("res://gui/modalUI/input.tscn")

func inputModal(title):
	var modal = inputModalScene.instantiate()
	menu.openUI(modal)
