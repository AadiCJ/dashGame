extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -200.0
const DASH_FACTOR = 3		
const MAX_DASHES = 3
var actualSpeed := SPEED
var dashes := 3


func _ready() -> void:
	SignalBus.dashPickedUp.connect(_on_dash_picked_up)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if dashes > 0 and direction:
		if Input.is_action_just_pressed("dash"):
			updateDashes(-1)
			actualSpeed = SPEED * DASH_FACTOR
			$Timer.start()
			SignalBus.dashStarted.emit()

	if direction:
		velocity.x = direction * actualSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, actualSpeed)

	move_and_slide()


func _on_timer_timeout() -> void:
	actualSpeed = SPEED	
	SignalBus.dashEnded.emit()

func _on_dash_picked_up() -> void:
	updateDashes(1)

func updateDashes(change: int) -> void:
	dashes = clamp(dashes+change, 0, MAX_DASHES)
	SignalBus.dashesUpdated.emit(dashes)
