extends Area2D


func _on_body_entered(_body:Node2D) -> void:
	var currentLevel = get_tree().current_scene.scene_file_path.to_int()
	SignalBus.levelEnd.emit(currentLevel)
	Transition.toIntermission()
	
