@tool
extends Button



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(_on_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_pressed():
	var gollama = $"../../../HBoxContainer/Button"
	gollama.server_address = $"../../ConfigAddress/Input".text
	gollama.server_port = $"../../ConfigPort/Input".text.to_int()
	gollama.server_url = $"../../ConfigUrl/Input".text
	gollama.server_model = $"../../ConfigModel/Input".text
	gollama.include_tscn = $"../../ConfigIncludeSenes/CheckBox".button_pressed
	$"../..".visible = false
	var config = ConfigFile.new()
	config.load("res://addons/gollama/plugin.cfg")
	for section in config.get_sections():
		if section.begins_with("config"):
			config.set_value(section, "include_tscn", gollama.include_tscn)
			config.set_value(section, "server_model", gollama.server_model)
			config.set_value(section, "server_address", gollama.server_address)
			config.set_value(section, "server_port", gollama.server_port)
			config.set_value(section, "server_url", gollama.server_url)
	config.save("res://addons/gollama/plugin.cfg")
