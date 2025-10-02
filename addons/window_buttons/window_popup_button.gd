@tool
@icon("./window_popup_button.svg")
class_name WindowPopupButton
extends Button

## WindowPopupButton
##
## Popups a window in the center of the relevent screen with an optional [member size_ratio].

## The (already instantiated) window to popup.
@export var window:Window = null:
	get:
		return window
	set(_value):
		if window != null:
			if window.visibility_changed.is_connected(_on_visibility_change):
				window.visibility_changed.disconnect(_on_visibility_change)
			if Engine.is_editor_hint():
				if window.title_changed.is_connected(notify_property_list_changed):
					window.title_changed.disconnect(notify_property_list_changed)
				if window.editor_state_changed.is_connected(notify_property_list_changed):
					window.editor_state_changed.disconnect(notify_property_list_changed)
		window = _value
		if window != null:
			if not window.visibility_changed.is_connected(_on_visibility_change):
				window.visibility_changed.connect(_on_visibility_change)
			if Engine.is_editor_hint():
				if not window.title_changed.is_connected(notify_property_list_changed):
					window.title_changed.connect(notify_property_list_changed)
				if not window.editor_state_changed.is_connected(notify_property_list_changed):
					window.editor_state_changed.connect(notify_property_list_changed)
		notify_property_list_changed()
		_on_visibility_change()

## When set, this button will always re-popup the window,
## even if the window is already visible.
@export var re_popup := false

## If set to a finite positive value, this will be the ratio used
## for the window being popped up.
@export var size_ratio:float = 0.0

## Makes the popup exclusive.[br]
## Regardless of this being set, the popup will always be exclusive
## if [method is_editor_popup] is [code]true[/code].
@export var force_exclusive := false

## A manual exclusive target override for the popup when it's created.
## When [code]null[/code], the exclusive target will be this button node.[br]
## see [member Window.exclusive] and [method Window.popup_exclusive]'s
## [param from_node] paramiter for more information.
@export var exclusive_target_override:Node = null

## When this is running in editor,
## this will force any popups to be an editor popup regardless of the window's parent.
@export var force_editor_popup := false

## Will set the given metadata of the targets window after popping it up.
## Keys of the [Dictionary] corelate to the meta name and must be [String]s,
## values corelate to the meta value and are [Variant].
## Metadata will always be set after parenting and before initialising properties values.
@export var initial_meta_values:Dictionary = {}

## Will set the given properties of the root of the scene when it is instantiated.
## Keys of the [Dictionary] corelate to the property name and must be [String]s,
## values corelate to the property's new value (whatever type that may be).
## Properties will always be set after parenting and after initialising metadata values.
@export var initial_property_values:Dictionary = {}

## Returns a [bool] determining if this button will currently choose to
## popup [member window] as a editor popup or a popup relative to the root node.[br]
## See [member force_editor_popup] for more information.[br]
## This will always be [code]false[/code] if not running in editor,
## and always [code]true[/code] if the [member window] is a child of the editor itself
## (but not of any edited scene).
func is_editor_popup() -> bool:
	if not Engine.is_editor_hint():
		return false
	if EditorInterface.get_editor_main_screen().get_viewport().is_ancestor_of(self):
		if not EditorInterface.get_edited_scene_root().is_ancestor_of(self):
			return true
	return force_editor_popup

func _property_can_revert(property: StringName) -> bool:
	match(property):
		"text", "force_exclusive":
			return true
	return false

func _property_get_revert(property: StringName) -> Variant:
	match(property):
		"text":
			return "Popup %s" % [_get_relevant_window_name()]
		"force_exclusive":
			return (window != null and window.exclusive) or force_editor_popup
	return null

func _on_visibility_change() -> void:
	if window != null:
		set_pressed_no_signal(window.visible)

func _get_relevant_window_name() -> String:
	if window == null:
		return ""
	if window.title != "":
		return window.title
	return window.name

func _ready() -> void:
	window = window

func _pressed() -> void:
	if toggle_mode:
		return
	_on_popup()

func _toggled(toggled_on: bool) -> void:
	if not toggle_mode:
		return
	if toggled_on:
		_on_popup()
	else:
		_on_popdown()

func _on_popup() -> void:
	if window == null:
		return

	for k in initial_meta_values.keys():
		window.set_meta(k, initial_meta_values[k])

	for k in initial_property_values.keys():
		if k in window:
			window.set(k, initial_property_values[k])

	if window.visible:
		if not re_popup:
			return
		_on_popdown()

	var use_ratio := size_ratio > 0 and is_finite(size_ratio)
	var p:Callable
	if is_editor_popup():
		if use_ratio:
			p = EditorInterface.popup_dialog_centered_ratio.bind(window, size_ratio)
		else:
			p = EditorInterface.popup_dialog_centered.bind(window)

		if window.get_parent() != null:
			window.get_parent().remove_child(window)
	else:
		if force_exclusive:
			var from_node = self
			if exclusive_target_override != null:
				from_node = exclusive_target_override

			if use_ratio:
				p = window.popup_exclusive_centered_ratio.bind(from_node, size_ratio)
			else:
				p = window.popup_exclusive_centered.bind(from_node)

			if window.get_parent() != null:
				window.get_parent().remove_child(window)
		else:
			if use_ratio:
				p = window.popup_centered_ratio.bind(size_ratio)
			else:
				p = window.popup_centered

	p.call()

func _on_popdown() -> void:
	if window == null or not window.visible:
		return
	window.hide()
