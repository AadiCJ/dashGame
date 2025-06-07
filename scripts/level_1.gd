extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Variables.isMobile:
		$Hints/DashHint.text = "Press the dash button (right side) to dash"