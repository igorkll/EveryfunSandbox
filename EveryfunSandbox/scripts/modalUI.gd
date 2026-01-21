extends Node

var inputModalScene = preload("res://gui/modalUI/input.tscn")

func inputModal(title, callback=null, value=""):
	var modal = inputModalScene.instantiate()
	funcs.ui_set_text(modal, "title", title)
	funcs.ui_set_text(modal, "input", value)
	funcs.ui_button_callback(modal, "cancel", close)
	funcs.ui_button_callback(modal, "confirm", func():
		if callback:
			callback.call(funcs.ui_get_text(modal, "input"))
		close()
	)
	menu.openUI(modal)

func textModal(text="test"):
	menu.showText(text)

func close():
	if menu.currentUI != 0 && menu.currentUI != 1:
		menu.switchUI(menu.backTo)
