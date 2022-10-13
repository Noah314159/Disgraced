extends Control

onready var mp_config_ui = $Multiplayer_config
onready var server_ip_address = $Multiplayer_config/Server_ip_address
onready var device_ip_address = $CanvasLayer/Device_ip_address

onready var start_game_btn = $CanvasLayer/Start_game

var player = load("res://scenes/playerScenes/Elementalist.tscn")

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	device_ip_address.text = Network.ip_address
	
	if get_tree().network_peer == null:
		start_game_btn.hide()


func _process(delta):
	if get_tree().network_peer != null and get_tree().is_network_server():
		start_game_btn.show()
	else:
		start_game_btn.hide()

func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")
	instance_player(id)

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")
	if Persistent_nodes.has_node(str(id)):
		Persistent_nodes.get_node(str(id)).queue_free()


func instance_player(id) -> void:
	var player_instance = Global.instance_node_at_location(player, Persistent_nodes, Vector2(rand_range(-300,300),rand_range(-300,300)))
	player_instance.name = str(id)
	player_instance.set_network_master(id)

func _on_Host_game_pressed():
	mp_config_ui.hide()
	Network.create_server()
	device_ip_address.text = Network.ip_address
	
	instance_player(get_tree().get_network_unique_id())

func _on_Join_game_pressed():
	if server_ip_address.text != "":
		mp_config_ui.hide()
		Network.ip_address = server_ip_address.text
		Network.join_server()

func _connected_to_server() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	instance_player(get_tree().get_network_unique_id())



func _on_Start_Game_pressed():
	rpc("switch_to_game")

sync func switch_to_game() -> void:
	get_tree().change_scene("res://scenes/gameWorldScenes/Game.tscn")
