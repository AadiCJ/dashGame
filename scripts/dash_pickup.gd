extends Area2D


func _on_body_entered(_body:Node2D) -> void:
    SignalBus.dashPickedUp.emit()
    #tell player dash was picked up
    queue_free()
    #remove the object
    #TODO: make this an animation that is played instead of removing it from here