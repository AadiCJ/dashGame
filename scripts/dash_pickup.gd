extends Area2D


func _on_body_entered(_body:Node2D) -> void:
    SignalBus.dashPickedUp.emit()
    #tell player dash was picked up
    $AnimatedSprite2D.visible = false
    $CollisionPolygon2D.queue_free()
    $PickupAudio.play()
    $DeleteTimer.start()


func _on_timeout() -> void:
    queue_free()
