extends CanvasLayer


const INTERMISSION_PATH = "res://levels/intermission.tscn"


func change_scene(target: String) -> void:
	$TextureRect.visible = true
	if ResourceLoader.exists(target):
		get_tree().call_deferred("change_scene_to_file", target)
	else:
		print("Error in changing scene")
	$AnimationPlayer.play_backwards("fadeToBlack")
	await $AnimationPlayer.animation_finished
	$TextureRect.visible = false
	Variables.deaths = 0


func toIntermission() -> void:
	$EndAudio.play()
	$TextureRect.visible = true
	$AnimationPlayer.play("fadeToBlack")
	await $AnimationPlayer.animation_finished
	get_tree().call_deferred("change_scene_to_file", INTERMISSION_PATH)
	$TextureRect.visible = false


func _ready() -> void:
	$TextureRect.visible = false
