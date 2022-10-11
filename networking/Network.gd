extends Node


const DEFAULT_PORT = 28960
const MAX_CLIENTS = 3

var server = null
var client = null

var ip_address = ""

func _ready():
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	elif OS.get_name() == "Android":
		ip_address = IP.get_local_addresses()[0]
	else:
		ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168."):
			ip_address = ip
			
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	


func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	
	var upnp = UPNP.new()

	
	var err = upnp.discover()
	var error1 = upnp.add_port_mapping(DEFAULT_PORT,0 ,"game test", "UDP", 0)
	var error2 = upnp.add_port_mapping(DEFAULT_PORT,0 ,"game test", "TCP", 0)
	ip_address= upnp.query_external_address()
	print(err)
	print(error1)
	print(error2)
	
	
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
