extends Area2D


func _ready() -> void:
	Variables.totalScore += Variables.scoreTypes.COIN

func _on_body_entered(_body:Node2D) -> void:
	SignalBus.scoreChange.emit(Variables.scoreTypes.COIN)
	$DeleteTimer.start()
	$CollisionShape2D.queue_free()
	$AnimatedSprite2D.visible = false
	$CoinAudio.play()


func _on_timeout() -> void:
	queue_free()
