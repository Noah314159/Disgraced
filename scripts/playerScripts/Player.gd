extends KinematicBody2D

onready var tween = $Tween


puppet var puppet_pos = Vector2.ZERO setget puppet_pos_set
puppet var puppet_velocity = Vector2()


const speed = 500

var velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if is_network_master():
		var x_input = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		var y_input = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		
		velocity = Vector2(x_input, y_input).normalized()
		
		move_and_slide(velocity * speed)
	else:
		if not tween.is_active():
			move_and_slide(puppet_velocity * speed)

#lag compnesation, interpolates players global position
func puppet_pos_set(value) -> void:
	puppet_pos = value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_pos, 0.1)
	tween.start()

#updates global position with the server tick rate
func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_pos", global_position)
		rset_unreliable("puppet_velocity", velocity)
