extends CharacterBody2D


const SPEED := 130.0
const JUMP_VELOCITY := -200.0
const DASH_FACTOR := 3.5		
const MAX_DASHES := 3
var actualSpeed := SPEED
var dashes := 3
var hasDied := false
var doubleJumped := false
var canDash := true
var mStyle = movementStyles.MOVE


func _ready() -> void:
	SignalBus.dashPickedUp.connect(_on_dash_picked_up)
	SignalBus.died.connect(_on_died)
	SignalBus.isClimbing.connect(_on_start_climbing)
	SignalBus.stoppedClimbing.connect(_on_stopped_climbing)
	

func _physics_process(delta: float) -> void:
	canDash = true
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * actualSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, actualSpeed)
	if mStyle == movementStyles.MOVE:
		#check if we're moving or climbing

		if not is_on_floor():
			#add gravity
			velocity += get_gravity() * delta
			#double jump handling
			if Input.is_action_pressed("jump") and Input.is_action_just_pressed("dash") and not doubleJumped and dashes > 0:
				updateDashes(-1)
				canDash = false
				doubleJumped = true
				velocity.y = -1 * SPEED * DASH_FACTOR

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY


		#TODO: make dashes work on double pressed of inputs
		if dashes > 0 and direction and canDash:
			if Input.is_action_just_pressed("dash"):
				canDash = false
				updateDashes(-1)
				actualSpeed = SPEED * DASH_FACTOR
				$DashTimer.start()
				SignalBus.dashStarted.emit()
				#dash started is used by enemeis to check whether they hurt or they die

		if is_on_floor():
			doubleJumped = false
		
	elif mStyle == movementStyles.CLIMB:
		direction = Input.get_axis("jump", "move_down")
		if direction:
			velocity.y = direction * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, actualSpeed)	
	
	move_and_slide()


func _on_timer_timeout() -> void:
	actualSpeed = SPEED	
	SignalBus.dashEnded.emit()
	#tell the enemies when the dash is over

func _on_dash_picked_up() -> void:
	updateDashes(1)

func updateDashes(change: int) -> void:
	dashes = clamp(dashes+change, 0, MAX_DASHES)
	SignalBus.dashesUpdated.emit(dashes)
	#tell the hud to update

func _on_died():
	#upward bounce when you die
	if not hasDied:
		velocity.y = -200
		hasDied = true
		#makes sure you don't keep bouncing forever

func _on_start_climbing():
	mStyle = movementStyles.CLIMB

func _on_stopped_climbing():
	mStyle = movementStyles.MOVE

enum movementStyles {
	MOVE,
	CLIMB
}