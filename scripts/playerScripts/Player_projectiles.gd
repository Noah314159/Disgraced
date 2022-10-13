extends Area2D

onready var initial_pos = global_position
onready var particles = $Particles2D

export(int) var speed = 400
export(int) var damage = 1

puppet var puppet_pos setget puppet_pos_set
puppet var puppet_direction = Vector2.ZERO
puppet var puppet_rot = 0

var direction = Vector2.RIGHT

func _ready():
	particles.emitting = true
	yield(get_tree(), "idle_frame")
	
	if is_network_master():
		direction = (get_global_mouse_position() - global_position).normalized()
		rotation = global_position.angle_to_point(get_global_mouse_position()) - PI/2
		rset("puppet_rot", rotation)
		rset("puppet_direction", direction)
		rset("puppet_pos", global_position)

func _process(delta):
	if is_network_master():
		global_position += direction * speed * delta
	else:
		rotation = puppet_rot
		global_position += puppet_direction * speed * delta

sync func destroy():
	queue_free()


func puppet_pos_set(value):
	puppet_pos = value
	global_position = puppet_pos

func _on_Delete_timer_timeout():
	if get_tree().is_network_server():
		rpc("destroy")


func _on_Area2D_area_entered(area):
	if get_tree().is_network_server():
		rpc("destroy")


func _on_Area2D_entered(body):
	if get_tree().is_network_server():
		rpc("destroy")
