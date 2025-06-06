extends CharacterBody2D


const DASH_FACTOR := 3.5		
const JUMP_FACTOR := 2
const MAX_DASHES := 3 
const LADDER_SPEED_REDUCTION = 0.5

var jumpPeakTime := 0.35
var jumpFallTime := 0.25
var jumpGravity: float = get_gravity().y

#proportional to increase in jump gravity
#and reduction in fall gravity
var gravityModulation = 1

#18 is one block
var jumpHeight := 54
var jumpDistance := 108


var speed: float 
var jumpVelocity: float
var fallGravity: float
var doubleJumpVelocity: float
var isMobile = Variables.isMobile

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
var canMove = true

var dashes := MAX_DASHES:
	set(value):
		dashes = clamp(value, 0, MAX_DASHES)
		SignalBus.dashesUpdated.emit(dashes)


var health = Variables.maxHealth:
	set(value):
		if value < health:
			$HurtAudio.play()
		health = value
		SignalBus.healthUpdated.emit(health)



func calcMovement() -> void:
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
	calcMovement()
	isMobile = true if OS.has_feature("mobile") else false
	SignalBus.dashPickedUp.connect(_on_dash_picked_up)
	SignalBus.died.connect(_on_died)
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
	mStyle = movementStyles.MOVE
	if not canMove:
		return
	
	if $RayLadder.get_collider():
		mStyle = movementStyles.CLIMB
	
	canDash = true
	#horizontal movement
	
	
	if is_on_wall_only():
		gravityModulation = 0.6

	if mStyle == movementStyles.MOVE:
		#check if we're moving or climbing

		var direction := Input.get_axis("move_left", "move_right")
		if direction and not hasDied:
			velocity.x = direction * actualSpeed
		else:
			velocity.x = move_toward(velocity.x, 0, actualSpeed)


		if not is_on_floor():
			canJump = false

			if not $CoyoteTimer.is_stopped():
				if Input.is_action_just_pressed("jump"):
					jump(false)

			#add gravity
			if velocity.y < 0:
				velocity.y += (jumpGravity * delta)/gravityModulation
			else:
				velocity.y += (fallGravity * delta)*gravityModulation
			#double jump handling
			if canDoubleJump():
				jump(true)
		else:
			#is on floor
			gravityModulation = 1 
			canJump = true
			if jumpBuffer:
				jump(false)
				jumpBuffer = false

		
		# Handle jump.
		if Input.is_action_just_pressed("jump") and not isMobile:
			if canJump or is_on_wall():
				jump(false)
			elif not is_on_floor():
				jumpBuffer = true
				$JumpBufferTimer.start()
		
		if Input.is_action_just_pressed("jumpMobile") and isMobile:
			if canJump or is_on_wall():
				jump(false)
				$JumpTimer.start()
			elif not is_on_floor():
				jumpBuffer = true

		#TODO: make dashes work on double pressed of inputs
		if Input.is_action_just_pressed("dash"):
			dash(direction)

		

		if is_on_floor():
			doubleJumped = false
			if velocityLastFrame > jumpFallTime * fallGravity + abs(doubleJumpVelocity) :
				health -= 1
		
	elif mStyle == movementStyles.CLIMB:
		var dir_y
		var dir_x
		if isMobile:
			dir_y = Input.get_axis("jumpMobile", "move_down")
		else:
			dir_y = Input.get_axis("jump", "move_down")
		
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



func jump(doubleJump: bool):
	if doubleJump:
		velocity.y = doubleJumpVelocity
		canDash = false
		dashes -= 1
		doubleJumped = true
	else:
		velocity.y -= jumpVelocity
	canJump = false
	$JumpAudio.play()



func canDoubleJump():
	var jumpPressed = false 
	if not isMobile:
		jumpPressed = Input.is_action_pressed("jump")
	else:
		jumpPressed = Input.is_action_pressed("jumpMobile") or not $JumpTimer.is_stopped()
	return jumpPressed and Input.is_action_just_pressed("dash") and not doubleJumped and dashes > 0 and not hasDied

func _on_dash_timer_timeout() -> void:
	actualSpeed = speed	
	$DashEndTimer.start()
	#tell the enemies when the dash is over

func _on_dash_picked_up() -> void:
	dashes += 1


func getTileSpeedReduction():
	var foregroundLayer: TileMapLayer = get_tree().get_first_node_in_group("Foreground")
	if not foregroundLayer:
		return null
	var cell := foregroundLayer.local_to_map(position)
	var data : TileData = foregroundLayer.get_cell_tile_data(cell)
	if data:
		return data.get_custom_data("speedReduction")
	
	return null

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

enum movementStyles {
	MOVE,
	CLIMB,
}


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
	canMove = false


func _on_jump_buffer_timer_timeout() -> void:
	jumpBuffer = false

func dash(direction) -> void:
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
				


func _on_dash_end_timer_timeout() -> void:
	SignalBus.dashEnded.emit()
