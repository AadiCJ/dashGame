extends Area2D


func _on_body_entered(_body:Node2D) -> void:
	SignalBus.scoreChange.emit(Variables.scoreTypes.COIN)
	queue_free()
