extends Node2D


const DAMAGE = 1
const SPEED = 80
var direction = 1
var canMove = true
var checks = 0
var forgiven = 0

func _physics_process(delta: float) -> void:
	if canMove == false:
		return

	if $RayRight.is_colliding():
		direction = -1
		checks += 1
	if $RayLeft.is_colliding():
		direction = 1
		checks += 1
	if not $RayLeftDown.is_colliding():
		direction = 1
		checks += 1
	if not $RayRightDown.is_colliding():
		direction = -1
		checks += 1

	position.x += direction * SPEED * delta

	print(checks/delta)
	if checks/delta >= 120:
		moveError()
	checks = 0

func moveError():
	forgiven += 1
	if forgiven > 3:
		print_debug("Error in movement, too many checks/delta")
		canMove = false


func _on_body_entered(_body:Node2D) -> void:
	SignalBus.damage.emit(1)
