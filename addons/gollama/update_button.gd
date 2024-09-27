@tool
extends Button



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(_on_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_pressed():
	$"../../../HBoxContainer/Button".server_address = $"../../ConfigAddress/Input".text
	$"../../../HBoxContainer/Button".server_port = $"../../ConfigPort/Input".text.to_int()
	$"../../../HBoxContainer/Button".server_url = $"../../ConfigUrl/Input".text
	var checkbox: CheckBox = $"../../ConfigIncludeSenes/CheckBox"
	$"../../../HBoxContainer/Button".include_tscn = $"../../ConfigIncludeSenes/CheckBox".button_pressed
	$"../..".visible = false
