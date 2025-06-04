extends CanvasLayer


func change_scene(target: String) -> void:
	#TODO: disable player movement
	$TextureRect.visible = true
	$AnimationPlayer.play("fadeToBlack")
	await $AnimationPlayer.animation_finished
	if ResourceLoader.exists(target):
		get_tree().call_deferred("change_scene_to_file", target)
	else:
		print("Error in changing scene")
	$AnimationPlayer.play_backwards("fadeToBlack")
	await $AnimationPlayer.animation_finished
	$TextureRect.visible = false
	Variables.deaths = 0

func _ready() -> void:
	$TextureRect.visible = false
