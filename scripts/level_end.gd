extends Area2D

const LEVEL_FOLDER = "res://levels/level_"

func _on_body_entered(_body:Node2D) -> void:
	var currentScene = get_tree().current_scene.scene_file_path
	var nextLevel = currentScene.to_int() + 1
	var nextLevelPath = LEVEL_FOLDER + str(nextLevel) + ".tscn"
	if ResourceLoader.exists(nextLevelPath):
		get_tree().call_deferred("change_scene_to_file", nextLevelPath)
	else:
		print("Error in changing level scene")    
		#if there isn't a next level, or its formatted wrong
	
