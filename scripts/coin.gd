extends Area2D


func _on_body_entered(_body:Node2D) -> void:
    SignalBus.scoreChange.emit(SignalBus.scoreTypes.COIN)
    queue_free()
