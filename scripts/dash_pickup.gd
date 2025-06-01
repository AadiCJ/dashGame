extends Area2D

signal dashPickedUp()


func _on_area_entered(_area:Area2D) -> void:
    dashPickedUp.emit()
    queue_free()

func _on_body_entered(_body:Node2D) -> void:
    dashPickedUp.emit()
    queue_free()