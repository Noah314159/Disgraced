extends KinematicBody2D
class_name Generic_player


onready var tween = $Tween
onready var camera = $Camera2D


#test
onready var player_projectile = preload("res://scenes/playerScenes/Player_projectiles.tscn")
#test

puppet var puppet_hp = 100 setget puppet_hp_set
puppet var puppet_pos = Vector2.ZERO setget puppet_pos_set
puppet var puppet_direction = Vector2()

const speed = 500


var hp = 100 setget set_hp


var direction = Vector2.ZERO

func _ready():
	yield(get_tree(), "idle_frame")
	if is_network_master():
		Global.player_master = self

func _physics_process(delta: float) -> void:
	if is_network_master():
		var x_input = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		var y_input = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		
		direction = Vector2(x_input, y_input).normalized()
		
		move_and_slide(direction * speed)
		
		#bullet testing
		if Input.is_action_just_pressed("primaryAttack"):
			rpc("instance_projectile", get_tree().get_network_unique_id())
		#bullet testing
		
	else:
		if not tween.is_active():
			move_and_slide(puppet_direction * speed)

#lag compnesation, interpolates players global position
func puppet_pos_set(value) -> void:
	puppet_pos = value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_pos, 0.1)
	tween.start()

sync func instance_projectile(id):
	var player_projectile_instance = Global.instance_node_at_location(player_projectile, Persistent_nodes, global_position)
	player_projectile_instance.name = "projectile" + name + str(Network.networked_obj_name_idx)
	player_projectile_instance.set_network_master(id)
	#player_projectile_instance.player_owner = id
	Network.networked_obj_name_idx += 1

func set_hp(value):
	hp = value
	if is_network_master():
		rset("puppet_hp", hp)

func puppet_hp_set(value):
	puppet_hp = value
	
	if not is_network_master():
		hp = puppet_hp

sync func destroy():
	if is_network_master():
		Global.player_master = null
		queue_free()

func _exit_tree():
	if is_network_master():
		Global.player_master = null

#updates global position with the server tick rate
func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_pos", global_position)
		rset_unreliable("puppet_direction", direction)
