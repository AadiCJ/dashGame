extends Node2D



func _on_body_entered(_body:Node2D) -> void:
	SignalBus.isClimbing.emit()


func _on_body_exited(_body:Node2D) -> void:
	SignalBus.stoppedClimbing.emit()
