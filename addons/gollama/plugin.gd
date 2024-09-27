@tool
extends EditorPlugin

var interface: Control

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		self.interface = load("res://addons/gollama/gollama.tscn").instantiate()
		add_control_to_dock(DOCK_SLOT_RIGHT_UL, self.interface)

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		remove_control_from_docks(self.interface)
		self.interface.free()
