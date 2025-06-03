extends CharacterBody2D


const SPEED := 130.0
const JUMP_VELOCITY := -200.0
const DASH_FACTOR := 3.5		
const MAX_DASHES := 3
const DOUBLE_JUMP_VELOCITY = -1 * SPEED * DASH_FACTOR

var actualSpeed := SPEED
var hasDied := false
var doubleJumped := false
var canDash := true
var mStyle = movementStyles.MOVE
var velocityLastFrame = 0
var score = 0 

var isDashing = false

var dashes := 3:
	set(value):
		dashes = clamp(value, 0, 3)
		SignalBus.dashesUpdated.emit(dashes)


var health = 3:
	set(value):
		health = value
		SignalBus.healthUpdated.emit(health)



func _ready() -> void:
	SignalBus.dashPickedUp.connect(_on_dash_picked_up)
	SignalBus.died.connect(_on_died)
	SignalBus.isClimbing.connect(_on_start_climbing)
	SignalBus.stoppedClimbing.connect(_on_stopped_climbing)
	SignalBus.dashStarted.connect(_on_started_dash)
	SignalBus.dashEnded.connect(_on_ended_dash)
	SignalBus.damage.connect(_on_damage)
	SignalBus.scoreChange.connect(_on_score_change)
	SignalBus.levelEnd.connect(_on_level_end)

func _process(_delta: float) -> void:
	if health <= 0:
		SignalBus.died.emit()
	
	if isDashing:
		$AnimatedSprite2D.play("dash")
	else:
		$AnimatedSprite2D.play("default")


func _physics_process(delta: float) -> void:
	canDash = true
	#horizontal movement
	var direction := Input.get_axis("move_left", "move_right")
	if direction and not hasDied:
		velocity.x = direction * actualSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, actualSpeed)

	if is_on_wall_only():
		velocity += get_gravity() * delta / 2 #reduce gravity to slide

	if mStyle == movementStyles.MOVE:
		#check if we're moving or climbing

		if not is_on_floor():
			#add gravity
			if not is_on_wall():
				velocity += get_gravity() * delta
			#double jump handling
			if (Input.is_action_pressed("jump") and Input.is_action_just_pressed("dash") 
				and not doubleJumped and dashes > 0 and not hasDied):
				dashes -= 1
				canDash = false
				doubleJumped = true
				velocity.y = DOUBLE_JUMP_VELOCITY

		# Handle jump.
		if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall()):
			#don't need to check if he's alive here, since collider is removed on death
			velocity.y = JUMP_VELOCITY


		#TODO: make dashes work on double pressed of inputs
		if dashes > 0 and direction and canDash:
			if Input.is_action_just_pressed("dash"):
				canDash = false
				dashes -= 1
				actualSpeed = SPEED * DASH_FACTOR
				$DashTimer.start()
				SignalBus.dashStarted.emit()
				#dash started is used by enemeis to check whether they hurt or they die

		if is_on_floor():
			doubleJumped = false
			if velocityLastFrame > abs(JUMP_VELOCITY + DOUBLE_JUMP_VELOCITY) - 100:
				health -= 1
		
	elif mStyle == movementStyles.CLIMB:
		direction = Input.get_axis("jump", "move_down")
		#climbing movement
		if direction and not hasDied:
			velocity.y = direction * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, actualSpeed)		
	
	velocityLastFrame = velocity.y
	move_and_slide()


func _on_dash_timer_timeout() -> void:
	actualSpeed = SPEED	
	SignalBus.dashEnded.emit()
	#tell the enemies when the dash is over

func _on_dash_picked_up() -> void:
	dashes += 1

func _on_died():
	#upward bounce when you die
	if not hasDied:
		health = 0
		velocity.y = -200
		hasDied = true
		$DeathTimer.start()
		$CollisionShape2D.queue_free()
		SignalBus.deaths += 1
		#makes sure you don't keep bouncing forever

func _on_start_climbing():
	mStyle = movementStyles.CLIMB

func _on_stopped_climbing():
	mStyle = movementStyles.MOVE

enum movementStyles {
	MOVE,
	CLIMB,
}


func _on_death_timer_timeout() -> void:
	get_tree().reload_current_scene()


func _on_started_dash():
	isDashing = true

func _on_ended_dash():
	isDashing = false

func _on_damage(damage: int):
	health -= damage

func _on_score_change(scoreChange: int):
	score += scoreChange

func _on_level_end(_currentLevel):
	SignalBus.displayScore.emit(score)
