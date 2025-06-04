extends CharacterBody2D


const DASH_FACTOR := 3.5		
const JUMP_FACTOR := 2
const MAX_DASHES := 3

var jumpPeakTime := 0.35
var jumpFallTime := 0.25

#18 is one block
var jumpHeight := 54
var jumpDistance := 108


var speed: float 
var jumpVelocity: float
var jumpGravity: float = get_gravity().y
var fallGravity: float
var doubleJumpVelocity: float


var actualSpeed := speed
var hasDied := false
var doubleJumped := false
var canDash := true
var mStyle = movementStyles.MOVE
var velocityLastFrame = 0
var score = 0 
var jumpBuffer := false
var isDashing = false
var canJump = true

var dashes := MAX_DASHES:
	set(value):
		dashes = clamp(value, 0, MAX_DASHES)
		SignalBus.dashesUpdated.emit(dashes)


var health = 3:
	set(value):
		health = value
		SignalBus.healthUpdated.emit(health)



func calcMovement() -> void:
	jumpGravity = (2*jumpHeight)/pow(jumpPeakTime, 2)
	fallGravity = (2*jumpHeight)/pow(jumpFallTime, 2)
	jumpVelocity = jumpGravity * jumpPeakTime
	speed = jumpDistance/(jumpPeakTime+jumpFallTime)
	actualSpeed = speed
	doubleJumpVelocity = -1 * speed * JUMP_FACTOR



func _ready() -> void:
	calcMovement()
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
	
	if isDashing or doubleJumped:
		$AnimatedSprite2D.play("dash")
	else:
		$AnimatedSprite2D.play("default")
	
	if not is_on_floor() and mStyle != movementStyles.CLIMB:
		$AnimatedSprite2D.rotate(0.2)
		#make him rotate mid air
	
	if is_on_floor():
		var rot = $AnimatedSprite2D.rotation_degrees
		rot = round(rot/90)
		$AnimatedSprite2D.rotation_degrees = rot*90





func _physics_process(delta: float) -> void:
	canDash = true
	#horizontal movement
	var direction := Input.get_axis("move_left", "move_right")
	if direction and not hasDied:
		velocity.x = direction * actualSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, actualSpeed)

	
	if is_on_wall_only():
		velocity += get_gravity() * delta / 2
		canJump = true

	if mStyle == movementStyles.MOVE:
		#check if we're moving or climbing

		if not is_on_floor() and not is_on_wall():
			#add gravity
			if velocity.y < 0:
				velocity.y += jumpGravity * delta
			else:
				velocity.y += fallGravity * delta
			#double jump handling
			if (Input.is_action_pressed("jump") and Input.is_action_just_pressed("dash") 
				and not doubleJumped and dashes > 0 and not hasDied):
				dashes -= 1
				canDash = false
				doubleJumped = true
				velocity.y = doubleJumpVelocity
		else:
			#is on floor
			canJump = true
			if jumpBuffer:
				jump()
				jumpBuffer = false

		
		# Handle jump.
		if Input.is_action_just_pressed("jump"):
			if canJump and is_on_floor():
				jump()
			elif not is_on_floor():
				jumpBuffer = true
				$JumpBufferTimer.start()


		#TODO: make dashes work on double pressed of inputs
		if dashes > 0 and direction and canDash:
			if Input.is_action_just_pressed("dash"):
				canDash = false
				dashes -= 1
				actualSpeed = speed * DASH_FACTOR
				$DashTimer.start()
				SignalBus.dashStarted.emit()
				#dash started is used by enemeis to check whether they hurt or they die

		if is_on_floor():
			doubleJumped = false
			if velocityLastFrame > jumpFallTime * fallGravity + abs(doubleJumpVelocity) :
				health -= 1
		
	elif mStyle == movementStyles.CLIMB:
		direction = Input.get_axis("jump", "move_down")
		#climbing movement
		if direction and not hasDied:
			velocity.y = direction * speed
		else:
			velocity.y = move_toward(velocity.y, 0, actualSpeed)		
	
	velocityLastFrame = velocity.y
	var was_on_floor = is_on_floor()
	move_and_slide()
	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		#if transitioned from being on the floor to not
		#and if not moving upwards
		$CoyoteTimer.start()



func jump():
	velocity.y -= jumpVelocity
	canJump = false



func _on_dash_timer_timeout() -> void:
	actualSpeed = speed	
	SignalBus.dashEnded.emit()
	#tell the enemies when the dash is over

func _on_dash_picked_up() -> void:
	dashes += 1

func _on_died():
	#upward bounce when you die
	if not hasDied:
		health = 0
		velocity.y = -jumpVelocity
		hasDied = true
		$DeathTimer.start()
		$CollisionShape2D.queue_free()
		Variables.deaths += 1
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


func _on_jump_buffer_timer_timeout() -> void:
	jumpBuffer = false
