extends CanvasLayer


@onready var label = $Label	

func _ready() -> void:
	SignalBus.dashesUpdated.connect(_on_dashes_updated)


func _on_dashes_updated(dashCount) -> void:
	label.text = str(dashCount)	
