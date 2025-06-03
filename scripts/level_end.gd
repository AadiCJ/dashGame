extends Area2D


func _on_body_entered(_body:Node2D) -> void:
	var currentLevel = get_tree().current_scene.scene_file_path.to_int()
	SignalBus.levelEnd.emit(currentLevel)

	var intermissionPath = "res://levels/intermission.tscn"
	if ResourceLoader.exists(intermissionPath):
		get_tree().call_deferred("change_scene_to_file", intermissionPath)
	else:
		print("Error in changing to intermission scene")    
	
