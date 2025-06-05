extends CharacterBody2D


@export var canMove = true
const DAMAGE = 1
const SPEED = 80
var direction = 1
var playerDashing = false
var applyGravity = false
var checks = 0
var forgiven = 0

func _ready() -> void:
	SignalBus.dashStarted.connect(dashStart)
	SignalBus.dashEnded.connect(dashEnd)

func dashStart():
	playerDashing = true

func dashEnd():
	playerDashing = false


func _process(_delta: float) -> void:
	if direction == 1:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false


func _physics_process(delta: float) -> void:
	if applyGravity:
		if velocity.y < 0:
			velocity.y += Variables.jumpGravity * delta
		else:
			velocity.y += Variables.fallGravity * delta
		move_and_slide()

	if canMove == false:
		return

	if $RayRight.is_colliding() or $RayRightPlayer.is_colliding():
		direction = -1
		checks += 1
	if $RayLeft.is_colliding() or $RayLeftPlayer.is_colliding():
		direction = 1
		checks += 1
	if not $RayLeftDown.is_colliding():
		direction = 1
		checks += 1
	if not $RayRightDown.is_colliding():
		direction = -1
		checks += 1

	position.x += direction * SPEED * delta

	if checks/delta >= 120:
		moveError()
	checks = 0

func moveError():
	forgiven += 1
	if forgiven > 3:
		print_debug("Error in movement, too many checks/delta")
		canMove = false


func _on_body_entered(_body:Node2D) -> void:
	if playerDashing:
		SignalBus.scoreChange.emit(Variables.scoreTypes.ENEMY)
		kill()
	else:
		SignalBus.damage.emit(1)


func kill():
	canMove = false
	applyGravity = true
	velocity.y = -Variables.jumpVelocity
	$KillAudio.play()
	$CollisionArea/CollisionPolygon2D.queue_free()
	$KillTimer.start()



func _on_timeout() -> void:
	queue_free()
