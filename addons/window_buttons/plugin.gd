@tool
extends EditorPlugin

const PLUGIN_NAME := "WindowPopupButtons"

const PLUGIN_ICON := preload("./window_mode_button.svg")

const ENSURE_SCRIPT_DOCS:Array[Script] = [
	preload("./window_popup_button.gd"),
	preload("./window_mode_button.gd"),
]

# Every once ands a while the script docs simply refuse to update properly.
# This nudges the docs into a ensuring that the important scripts added by
# this addon are actually loaded.
func _ensure_script_docs():
	var edit := get_editor_interface().get_script_editor()
	for scr in ENSURE_SCRIPT_DOCS:
		edit.update_docs_from_script(scr)

func _get_plugin_name() -> String:
	return PLUGIN_NAME

func _get_plugin_icon() -> Texture2D:
	return PLUGIN_ICON

func _enter_tree() -> void:
	_ensure_script_docs()

func _enable_plugin() -> void:
	_ensure_script_docs()
