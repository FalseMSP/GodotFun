extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var cyote_timer = $CyoteTime

func _physics_process(delta: float) -> void:
	#velocity.x = -300
	#print(velocity)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() || not cyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY
		

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		var temp = max(abs(velocity.x), SPEED)
		velocity.x = temp * direction;
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	#Cyote Time helper
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	if was_on_floor && !is_on_floor():
		cyote_timer.start()
