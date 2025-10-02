@tool
@icon("./window_mode_button.svg")
class_name WindowModeButton
extends Button

## WindowModeButton
##
## A button that changes (or toggles) the [member Window.mode] of a
## given [member window].

## The target window to change the [member Window.mode] of.
## [b]NOTE[/b] that while this will change the [member Window.mode]
## of any window, the mode will only take effect on native windows.
@export var window:Window = null:
	get:
		return window
	set(_value):
		if window != null:
			if window.property_list_changed.is_connected(_on_window_property_changed):
				window.property_list_changed.disconnect(_on_window_property_changed)
			if Engine.is_editor_hint():
				if window.title_changed.is_connected(notify_property_list_changed):
					window.title_changed.disconnect(notify_property_list_changed)
				if window.editor_state_changed.is_connected(notify_property_list_changed):
					window.editor_state_changed.disconnect(notify_property_list_changed)
		window = _value
		if window != null:
			if not window.property_list_changed.is_connected(_on_window_property_changed):
				window.property_list_changed.connect(_on_window_property_changed)
			if Engine.is_editor_hint():
				if not window.title_changed.is_connected(notify_property_list_changed):
					window.title_changed.connect(notify_property_list_changed)
				if not window.editor_state_changed.is_connected(notify_property_list_changed):
					window.editor_state_changed.connect(notify_property_list_changed)
		notify_property_list_changed()
		_on_window_property_changed()

## The [enum Window.Mode] to change [member window]'s [member Window.mode]
## to when this button is pressed (or toggled down).
@export var active_state:Window.Mode = Window.MODE_WINDOWED:
	get:
		return active_state
	set(_value):
		active_state = _value
		update_configuration_warnings()

## When set, this will allow for [member inactive_state] to apply when this
## button is toggled. This will only mean anything when the button is toggled.
@export var explicit_inactive_state := false:
	get:
		return explicit_inactive_state
	set(_value):
		explicit_inactive_state = _value
		notify_property_list_changed()
		update_configuration_warnings()

## The [enum Window.Mode] to change [member window]'s [member Window.mode]
## to when this button is toggled up (though not when released).
## Note that this will have no effect
## unless [enum Button.toggle_mode] [b]and[/b] [member explicit_inactive_state]
## are both set.
@export var inactive_state:Window.Mode = Window.MODE_MINIMIZED:
	get:
		return inactive_state
	set(_value):
		inactive_state = _value
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warn := PackedStringArray()
	if toggle_mode and explicit_inactive_state and active_state == inactive_state:
		var m := "[code]active_state[/code] matches [code]inactive_state[/code],"
		m += " toggling this button off will have no effect."
		warn.append(m)
	return warn

func _validate_property(property: Dictionary) -> void:
	match(property.name):
		# #Currently not possible, as [member toggle_mode] does not trigger [signal property_list_changed]
		# "explicit_inactive_state", "inactive_state" when not toggle_mode:
		# 	property.usage &= ~PROPERTY_USAGE_EDITOR
		"inactive_state" when not explicit_inactive_state:
			property.usage &= ~PROPERTY_USAGE_EDITOR

func _property_can_revert(property: StringName) -> bool:
	match(property):
		"text":
			return true
	return false

func _property_get_revert(property: StringName) -> Variant:
	match(property):
		"text":
			return _get_relevant_window_name()
	return null

func _get_relevant_window_name() -> String:
	if window == null:
		return ""
	if window.title != "":
		return window.title
	return window.name

func _on_window_property_changed() -> void:
	if window == null:
		return
	if explicit_inactive_state and active_state == inactive_state:
		set_pressed_no_signal(false)
	else:
		set_pressed_no_signal(window.mode == active_state)

func _on_active() -> void:
	if window == null:
		return
	window.mode = active_state

func _on_inactive() -> void:
	if window == null:
		return
	if explicit_inactive_state:
		window.mode = inactive_state

func _ready() -> void:
	window = window

func _pressed() -> void:
	if toggle_mode:
		return
	_on_active()

func _toggled(toggled_on: bool) -> void:
	if not toggle_mode:
		return
	if toggled_on:
		_on_active()
	else:
		_on_inactive()
