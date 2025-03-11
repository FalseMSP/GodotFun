extends CharacterBody2D


const SPEED = 300.0
const AIR_RESISTANCE = 20.0
const JUMP_VELOCITY = -400.0
const FRICTION = 100
const DASH_SPEED = 450

@onready var cyote_timer = $CyoteTime
@onready var dash_timer = $DashTimer
@onready var jump_buffer_timer = $JumpTimer

var dashReady = true
var facing = 1

# bufferable inputs
var jumpBuffer = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and dash_timer.is_stopped():
		velocity += get_gravity() * delta

	# Handle jump.
	# input JumpBuffer
	if Input.is_action_just_pressed("jump"):
		jumpBuffer = true
		jump_buffer_timer.start()
	
	if jump_buffer_timer.is_stopped() || not Input.is_action_pressed("jump"):
		jumpBuffer = false
	
	if jumpBuffer and (is_on_floor() || not cyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY
		jumpBuffer = false
		jump_buffer_timer.stop()
	
		

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction and dash_timer.is_stopped():
		if is_on_floor():
			var temp = max(abs(velocity.x), SPEED)
			velocity.x = temp * direction;
		else: # not on floor
			if SPEED > abs(velocity.x):
				var temp = max(abs(velocity.x), SPEED)
				velocity.x = temp * direction;
			else:
				velocity.x = move_toward(velocity.x, SPEED, AIR_RESISTANCE)
	else:
		if not is_on_floor() and dash_timer.is_stopped():
			velocity.x = move_toward(velocity.x, 0, AIR_RESISTANCE)
		elif dash_timer.is_stopped():
			velocity.x = move_toward(velocity.x, 0, FRICTION)
	
	# Dash mechanic
	if velocity.x != 0:
		facing = 1 if velocity.x > 0 else -1
	var directionY := Input.get_axis("move_up", "move_down")
	var dashing = Input.is_action_pressed("dash")
	if dashing and dashReady:
		if max(abs(direction),abs(directionY)) == 0:
			velocity.x = DASH_SPEED * facing
			velocity.y = 0
		else:
			velocity.x = DASH_SPEED * direction * 1/sqrt(pow(direction,2)+pow(directionY,2))
			velocity.y = DASH_SPEED * directionY * 1/sqrt(pow(direction,2)+pow(directionY,2))
		dashReady = false
		dash_timer.start()
	
	if is_on_floor():
		dashReady = true
		dash_timer.stop()
	
	#Cyote Time helper
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	if was_on_floor && !is_on_floor():
		cyote_timer.start()
