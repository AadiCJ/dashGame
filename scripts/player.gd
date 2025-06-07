extends CharacterBody2D


# CONSTANTS
const DASH_FACTOR := 3.5		
const JUMP_FACTOR := 2
const MAX_DASHES := 3 
const LADDER_SPEED_REDUCTION = 0.5



# EXTRA VARIABLES
var gravityModulation = 1 #proportional to increase in jump gravity and reduction in fall gravity
var actualSpeed := speed
var velocityLastFrame = 0
var score = 0 



# JUMP VARIABLES
var jumpPeakTime := 0.35
var jumpFallTime := 0.25
var jumpGravity: float = get_gravity().y
var jumpHeight := 54
var jumpDistance := 108
#18 is one block


# CALCULATED VARIABLES
var speed: float 
var jumpVelocity: float
var fallGravity: float
var doubleJumpVelocity: float
var isMobile = Variables.isMobile


#STATE VARIABLES
var hasDied := false
var doubleJumped := false
var canDash := true
var mStyle = movementStyles.MOVE
var jumpBuffer := false
var isDashing = false
var canJump = true
var canMove = true
enum movementStyles {
	MOVE,
	CLIMB,
}



# DASHES
var dashes := MAX_DASHES:
	set(value):
		dashes = clamp(value, 0, MAX_DASHES)
		SignalBus.dashesUpdated.emit(dashes)


# HEALTH
var health = Variables.maxHealth:
	set(value):
		if value < health:
			$HurtAudio.play()
		health = value
		SignalBus.healthUpdated.emit(health)


# calculates movement variables.
func _calcMovement() -> void:
	jumpGravity = (2*jumpHeight)/pow(jumpPeakTime, 2)
	fallGravity = (2*jumpHeight)/pow(jumpFallTime, 2)
	jumpVelocity = jumpGravity * jumpPeakTime
	speed = jumpDistance/(jumpPeakTime+jumpFallTime)
	actualSpeed = speed
	doubleJumpVelocity = -1 * speed * JUMP_FACTOR
	Variables.fallGravity = fallGravity
	Variables.jumpGravity = jumpGravity
	Variables.jumpVelocity = jumpVelocity



func _ready() -> void:
	Variables.currentLevelScore = 0
	_calcMovement()
	isMobile = true if OS.has_feature("mobile") else false
	SignalBus.dashPickedUp.connect(_on_dash_picked_up)
	SignalBus.died.connect(_on_died)
	SignalBus.dashStarted.connect(_on_started_dash)
	SignalBus.dashEnded.connect(_on_ended_dash)
	SignalBus.damage.connect(_on_damage)
	SignalBus.scoreChange.connect(_on_score_change)
	SignalBus.levelEnd.connect(_on_level_end)



# animations and sprite changes handled here
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




#movement, and other physics related processes
func _physics_process(delta: float) -> void:
	mStyle = movementStyles.MOVE
	if not canMove:
		return
	
	if $RayLadder.get_collider():
		mStyle = movementStyles.CLIMB
	
	canDash = true
	#horizontal movement
	
	#slide slower on walls
	if is_on_wall_only():
		gravityModulation = 0.6

	if mStyle == movementStyles.MOVE:
		#check if we're moving or climbing

		var direction := Input.get_axis("move_left", "move_right")
		if direction and not hasDied:
			velocity.x = direction * actualSpeed
		else:
			velocity.x = move_toward(velocity.x, 0, actualSpeed)
		#handle x movmenet

		if not is_on_floor():
			canJump = false
			#allow for coyote time
			if not $CoyoteTimer.is_stopped():
				if Input.is_action_just_pressed("jump"):
					_jump(false)


			#add gravity
			if velocity.y < 0:
				velocity.y += (jumpGravity * delta)/gravityModulation
			else:
				velocity.y += (fallGravity * delta)*gravityModulation

			#double jump handling
			if _canDoubleJump():
				_jump(true)

		else:
			#is on floor
			gravityModulation = 1 #reset gravity 
			canJump = true 
			if jumpBuffer:
				_jump(false) #if jump was buffered, then jump 
				jumpBuffer = false #don't keep jumping dumb ahh

		
		# handle jump
		if Input.is_action_just_pressed("jump"):
			if canJump or is_on_wall(): #allows for spidering
				_jump(false)
				$JumpTimer.start() #added double jump time to pc too
			elif not is_on_floor():
				jumpBuffer = true
				$JumpBufferTimer.start() 

		#TODO: make dashes work on double pressed of inputs
		if Input.is_action_just_pressed("dash"):
			_dash(direction)

		

		if is_on_floor():
			doubleJumped = false
			#check if we were too fast last frame, take damage
			if velocityLastFrame > jumpFallTime * fallGravity + abs(doubleJumpVelocity) :
				health -= 1
			#calculation is normal jump height + double jump height total velocity

	elif mStyle == movementStyles.CLIMB:
		var dir_y
		var dir_x
		dir_y = Input.get_axis("jump", "move_down")#handle climbing input
		dir_x = Input.get_axis("move_left", "move_right")
		velocity.x = dir_x * speed * LADDER_SPEED_REDUCTION	
		velocity.y = dir_y * speed
			
	
	velocityLastFrame = velocity.y
	var was_on_floor = is_on_floor()

	move_and_slide()

	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		#if transitioned from being on the floor to not
		#and if not moving upwards
		$CoyoteTimer.start() 


# SPECIAL MOVEMENT FUNCTIONS

func _jump(doubleJump: bool):
	if doubleJump:
		velocity.y = doubleJumpVelocity
		canDash = false
		dashes -= 1
		doubleJumped = true
	else:
		velocity.y -= jumpVelocity
	canJump = false
	$JumpAudio.play()


func _dash(direction) -> void:
	if hasDied:
		return 
		#don't dash if we're dead lol
	if dashes <= 0 or not canDash or not direction:
		return 

	canDash = false
	dashes -= 1
	actualSpeed = speed * DASH_FACTOR
	$DashTimer.start()
	SignalBus.dashStarted.emit()
	#dash started is used by enemeis to check whether they hurt or they die
		

func _canDoubleJump():
	var jumpPressed = Input.is_action_pressed("jump") or not $JumpTimer.is_stopped()
	return jumpPressed and Input.is_action_just_pressed("dash") and not doubleJumped and dashes > 0 and not hasDied

func _on_dash_timer_timeout() -> void:
	actualSpeed = speed	
	$DashEndTimer.start()
	#adds a little extra time to the end of your dash to deal damage




# SIGNALS BEYOND THIS
func _on_dash_picked_up() -> void:
	dashes += 1


func _on_died():
	#prevents this method from being called repeatedly
	if not hasDied:
		health = 0 #just incase some other function called it before health actually reached zero
		velocity.y = -jumpVelocity #bounce upward
		hasDied = true
		$DeathTimer.start()
		$MainCollider.queue_free()
		$DeathAudio.play()
		Variables.deaths += 1
		#death tracker to ensure deaths are displayed 


func _on_death_timer_timeout() -> void:
	get_tree().reload_current_scene()

func _on_started_dash():
	$DashAudio.play()
	isDashing = true

func _on_ended_dash():
	isDashing = false

func _on_damage(damage: int):
	health -= damage

func _on_score_change(scoreChange: int):
	score += scoreChange

func _on_level_end(_currentLevel):
	SignalBus.displayScore.emit(score)
	Variables.dashes = dashes
	canMove = false

func _on_jump_buffer_timer_timeout() -> void:
	jumpBuffer = false
		
func _on_dash_end_timer_timeout() -> void:
	SignalBus.dashEnded.emit()
