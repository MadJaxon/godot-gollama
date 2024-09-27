@tool
extends Button

@onready var input_address: TextEdit = $"../../ConfigContainer/ConfigAddress/Input"
@onready var input_port: TextEdit = $"../../ConfigContainer/ConfigPort/Input"
@onready var input_url: TextEdit = $"../../ConfigContainer/ConfigUrl/Input"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(_on_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_pressed():
	$"../../ConfigContainer".visible = !$"../../ConfigContainer".visible
