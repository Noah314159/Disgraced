extends Control

onready var mp_config_ui = $Multiplayer_config
onready var server_ip_address = $Multiplayer_config/Server_ip_address
onready var device_ip_address = $CanvasLayer/Device_ip_address

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	device_ip_address.text = Network.ip_address



func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")


func _on_Host_game_pressed():
	mp_config_ui.hide()
	Network.create_server()
	device_ip_address.text = Network.ip_address

func _on_Join_game_pressed():
	if server_ip_address.text != "":
		mp_config_ui.hide()
		Network.ip_address = server_ip_address.text
		Network.join_server()
