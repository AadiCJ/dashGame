extends CharacterBody2D


const SPEED := 130.0
const JUMP_VELOCITY := -200.0
const DASH_FACTOR := 3.5		
const MAX_DASHES := 3
const DOUBLE_JUMP_VELOCITY = -1 * SPEED * DASH_FACTOR

var actualSpeed := SPEED
var dashes := 3
var hasDied := false
var doubleJumped := false
var canDash := true
var mStyle = movementStyles.MOVE
var velocityLastFrame = 0
var health = 3:
	set(value):
		health = value
		SignalBus.healthUpdated.emit(health)



func _ready() -> void:
	SignalBus.dashPickedUp.connect(_on_dash_picked_up)
	SignalBus.died.connect(_on_died)
	SignalBus.isClimbing.connect(_on_start_climbing)
	SignalBus.stoppedClimbing.connect(_on_stopped_climbing)
	

func _process(_delta: float) -> void:
	if health <= 0:
		SignalBus.died.emit()


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

				updateDashes(-1)
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
				updateDashes(-1)
				actualSpeed = SPEED * DASH_FACTOR
				$DashTimer.start()
				SignalBus.dashStarted.emit()
				#dash started is used by enemeis to check whether they hurt or they die

		if is_on_floor():
			doubleJumped = false
			if velocityLastFrame > abs(JUMP_VELOCITY + DOUBLE_JUMP_VELOCITY) - 150:
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
	updateDashes(1)

func updateDashes(change: int) -> void:
	dashes = clamp(dashes+change, 0, MAX_DASHES)
	SignalBus.dashesUpdated.emit(dashes)
	#tell the hud to update

func _on_died():
	#upward bounce when you die
	if not hasDied:
		health = 0
		velocity.y = -200
		hasDied = true
		$DeathTimer.start()
		$CollisionShape2D.queue_free()
		#makes sure you don't keep bouncing forever

func _on_start_climbing():
	mStyle = movementStyles.CLIMB

func _on_stopped_climbing():
	mStyle = movementStyles.MOVE

enum movementStyles {
	MOVE,
	CLIMB,
	WALL
}


func _on_death_timer_timeout() -> void:
	get_tree().reload_current_scene()
