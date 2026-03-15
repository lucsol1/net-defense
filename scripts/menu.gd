extends Control

func _on_search_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_match.tscn")
	pass 


func _on_exiit_pressed() -> void:
	get_tree().quit()
	pass 
