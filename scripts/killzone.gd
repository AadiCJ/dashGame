extends Area2D


func _ready() -> void:
	 #TODO: make dying a signal that is picked up here,
	#but can also be emitted by enemies
	pass

func _on_body_entered(_body:Node2D) -> void:
	SignalBus.died.emit()
	#tell player it has died
	$Timer.start()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	#restart after some time
