extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -200.0
const DASH_FACTOR = 3		
const MAX_DASHES = 3
var actualSpeed := SPEED
var dashes := 3
var hasDied := false
var doubleJumped := false

func _ready() -> void:
	SignalBus.dashPickedUp.connect(_on_dash_picked_up)
	SignalBus.died.connect(_on_died)

	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	var dashedNow = false
	if not is_on_floor():
		velocity += get_gravity() * delta
		if Input.is_action_pressed("jump") and Input.is_action_just_pressed("dash") and not doubleJumped and dashes > 0:
			updateDashes(-1)
			dashedNow = true
			doubleJumped = true
			velocity.y = -1 * SPEED * DASH_FACTOR

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	
	var direction := Input.get_axis("move_left", "move_right")
	
	#TODO: make dashes work on double pressed of inputs
	if dashes > 0 and direction and not dashedNow:
		if Input.is_action_just_pressed("dash"):
			updateDashes(-1)
			actualSpeed = SPEED * DASH_FACTOR
			$DashTimer.start()
			SignalBus.dashStarted.emit()
			#dash started is used by enemeis to check whether they hurt or they die

	if is_on_floor():
		doubleJumped = false

	if direction:
		velocity.x = direction * actualSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, actualSpeed)

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