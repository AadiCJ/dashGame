extends Area2D



func _on_body_entered(_body:Node2D) -> void:
    var currentScene = get_tree().current_scene.scene_file_path
    var nextLevel = currentScene.to_int() + 1
    print(nextLevel)

