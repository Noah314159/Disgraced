extends Area2D


signal damage_taken(damage)

onready var detection_area = $CollisionShape2D
onready var hit_timer = $hit_timer


func _on_Hurtbox_area_entered(area):
	emit_signal("damage_taken", area.damage)
	set_deferred("monitoring", false)
	hit_timer.start(0.1)


func _on_hit_timer_timeout():
	set_deferred("monitoring", true)
