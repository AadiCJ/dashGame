extends CanvasLayer


@onready var gm = %GameManager
@onready var label = $Label




func _on_game_manager_dash_updated() -> void:
	var dashes = str(gm.dashes)
	label.text = dashes
