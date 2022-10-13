extends Area2D


var players_in_area = []

signal players_in_area_changed(players)


func _on_Player_detection_area_body_entered(body):
	players_in_area.append(body)
	emit_signal("players_in_area_changed", players_in_area)


func _on_Player_detection_area_body_exited(body):
	players_in_area.erase(body)
	
	emit_signal("players_in_area_changed", players_in_area)
	
