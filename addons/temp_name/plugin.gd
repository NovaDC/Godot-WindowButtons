@tool
extends EditorPlugin

const PLUGIN_NAME := "temp_name"
const PLUGIN_ICON := preload("res://addons/temp_name/icon.svg")

func _enter_tree() -> void:
	if EditorInterface.is_plugin_enabled(PLUGIN_NAME):
		_init_plugin()

func _exit_tree() -> void:
	_deinit_plugin()

func _enable_plugin() -> void:
	_init_plugin()

func _disable_plugin() -> void:
	_deinit_plugin()

func _get_plugin_name() -> String:
	return PLUGIN_NAME

func _get_plugin_icon() -> Texture2D:
	return PLUGIN_ICON

func _init_plugin():
	pass #TODO

func _deinit_plugin():
	pass #TODO
