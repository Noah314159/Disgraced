extends Area2D


var hp = 1

var direction = Vector2.ZERO
var speed = 200
var players_in_range = []

var player_to_follow = null

func _physics_process(delta):
	if players_in_range.size() != 0:
		player_to_follow = players_in_range[0]
		direction = (player_to_follow.global_position - global_position).normalized()
		
		
		position += transform.x * direction.x * speed * delta
		position += transform.y * direction.y * speed * delta
	else:
		player_to_follow = null


func _on_Player_detection_area_players_in_area_changed(players):
	players_in_range = players


func _on_Hurtbox_damage_taken(damage):
	queue_free()
