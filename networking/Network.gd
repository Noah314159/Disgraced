extends Node

onready var upnp = UPNP.new()

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 3

var server = null
var client = null

var ip_address = ""


var networked_obj_name_idx = 0 setget networked_obj_name_idx_set
puppet var puppet_networked_obj_name_idx = 0 setget puppet_networked_obj_name_idx_set

func _ready():
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	elif OS.get_name() == "Android":
		ip_address = IP.get_local_addresses()[0]
	else:
		ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			ip_address = ip
			
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	


func create_server() -> void:
	server = NetworkedMultiplayerENet.new()


	var err = upnp.discover()
	print(err)
	ip_address = upnp.query_external_address()
	
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)

func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)


func _connected_to_server() -> void:
	print("Successfully connected to server")

func _server_disconnected() -> void:
	print("Disconnected from server")


func puppet_networked_obj_name_idx_set(value):
	networked_obj_name_idx = value

func networked_obj_name_idx_set(value):
	networked_obj_name_idx = value
	if get_tree().is_network_server():
		rset("puppet_networked_obj_name_idx", networked_obj_name_idx)
