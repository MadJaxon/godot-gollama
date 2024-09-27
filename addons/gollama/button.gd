@tool
extends Button

@export var server_address: String = "127.0.0.1"
@export var server_port: int = 11434
@export var server_url: String = "/api/generate"
@export var include_tscn: bool = true

@export var height: int = 500 :
	set(h):
		height = h
		self.chat.set_custom_minimum_size(Vector2(0, h))
@export_dir var directory_path: String = "res://"

@onready var http_mutex: Mutex = Mutex.new()
@onready var chat: RichTextLabel = $"../../Chat"
@onready var input_prompt: TextEdit = $"../PromptInput"

@onready var input_address: TextEdit = $"../../ConfigContainer/ConfigAddress/Input"
@onready var input_port: TextEdit = $"../../ConfigContainer/ConfigPort/Input"
@onready var input_url: TextEdit = $"../../ConfigContainer/ConfigUrl/Input"


var http_thread: Thread = null

var prompt: String = ''
var messages: Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_button_pressed)
	self.chat.set_custom_minimum_size(Vector2(0, self.height))
	self.input_address.text = self.server_address
	self.input_port.text = str(self.server_port)
	self.input_url.text = self.server_url


func _exit_tree():
	if self.http_thread != null:
		self.http_thread.wait_to_finish()



func _on_button_pressed():
	var concatenated_text = concatenate_files(directory_path)
	self.prompt = "[File Structure]\n" + \
			concatenated_text
	if !self.messages.is_empty():
		self.prompt += "\n\n\n\n[Conversation Histroy]\n" + \
				self.messages.reduce(func(carry, item: String): return carry + item + "\n\n##########\n\n", "")
	self.prompt += "\n\n\n\n[Prompt]\n" + \
			$"../PromptInput".text
	self.add_message($"../PromptInput".text)
	$"../PromptInput".text = ''
	if self.http_thread != null:
		self.http_thread.wait_to_finish()
	self.http_thread = Thread.new()
	self.http_thread.start(send_to_ollama)

	

func concatenate_files(path) -> String:
	if path == 'res://addons/gollama/':
		return ''
	var directory = DirAccess.open(path)
	if directory.dir_exists(path):
		directory.include_hidden = false
		directory.include_navigational = false
		var subDirs = directory.get_directories()
		var files = directory.get_files()
		var full_text = ""
		for filePath in files:
			if filePath.ends_with(".gd") or (self.include_tscn and filePath.ends_with(".tscn")):
				if FileAccess.file_exists(path + filePath):
					var file = FileAccess.open(path + filePath, FileAccess.READ)
					full_text += "\n\n########################\n#### File \"" + path + filePath + "\" ####\n########################\n"
					full_text += file.get_as_text()
				else:
					print("file not found: " + path + filePath)
		for dir in subDirs:
			full_text += self.concatenate_files(path + dir + '/')
		return full_text
	else:
		return "Error: Directory not found."

func toggleButton():
	self.http_mutex.lock()
	self.disabled = !self.disabled
	self.http_mutex.unlock()

func clear_messages():
	self.messages = []
	$"../../Chat".text = ""

func add_message(message: String, add_to_log: bool = true):
	self.http_mutex.lock()
	if add_to_log:
		self.messages.append(message)
	$"../../Chat".text += "# # # # # # # # # # # #\n" + message + "\n"
	$"../../Chat".scroll_to_line( $"../../Chat".get_line_count() - 1 )
	self.http_mutex.unlock()

func send_to_ollama():
	# Here you would typically make an HTTP request or use a Godot network module
	# to communicate with Ollama. Below is a placeholder:
	call_deferred("toggleButton")
	var http = HTTPClient.new()
	http.blocking_mode_enabled = true
	var result = http.connect_to_host(self.server_address, self.server_port)
	if result != OK:
		print("Failed to connect to Ollama")
		call_deferred("toggleButton")
		return
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		OS.delay_msec(100)

	var body = JSON.stringify({
		"model": "llama3.2",
		"stream": false,
		"prompt": self.prompt
	})
	var headers = [
		"User-Agent: godot-gollama",
		"Content-Type: application/json",
		"Content-Length: " + str(body.length())
	]
	var request = http.request(HTTPClient.METHOD_POST, self.server_url, headers, body)
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		OS.delay_msec(100)
	
	
	if http.has_response():
		var rb = PackedByteArray()
		while http.get_status() == HTTPClient.STATUS_BODY:
			# While there is body left to be read
			http.poll()
			# Get a chunk.
			var chunk = http.read_response_body_chunk()
			if chunk.size() == 0:
				await get_tree().process_frame
			else:
				rb = rb + chunk # Append to read buffer.

		var response_json = JSON.parse_string(rb.get_string_from_ascii())
		var response: String = response_json.response
		response.replace("\\n", "\n")
		call_deferred("add_message", response)
	call_deferred("toggleButton")
