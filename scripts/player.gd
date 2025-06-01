extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -200.0
const DASH_FACTOR = 30
@onready var gm = %GameManager


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
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash"):
		dash()


func dash():
	if gm.dashes <= 0:
		return
	var direction := Input.get_axis("move_left", "move_right")

	if direction:
		velocity.x = direction * SPEED * DASH_FACTOR
		gm.dashes = -1
	else: 
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	#damage anything inside its movement path
	#move FAST to a spefic direction
