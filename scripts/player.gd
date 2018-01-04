extends RigidBody2D

var input_states = preload("res://scripts/input_states.gd")

var btn_right = input_states.new("btn_right")
var btn_left = input_states.new("btn_left")
var btn_jump = input_states.new("btn_jump")
var btn_run = input_states.new("btn_run")

export var move_speed = 400
export var run_speed = 600
export var move_accel = 3
export var air_accel = 2
export var extra_mass = 300
export var jump_force = -300
export var max_jumps = 2
export var air_accel_mult = 2/3
var curr_jumps = 0
var curr_vel = Vector2(0, 0)
var raycast_down = null
var rotate_node = null

var PLAYER_STATE_PREV = ""
var PLAYER_STATE = ""
var PLAYER_STATE_NEXT = ""

var ORIENTATION_PREV = ""
var ORIENTATION = ""
var ORIENTATION_NEXT = ""

func move(vel, acc, delta):
	curr_vel.x = lerp(curr_vel.x, vel, acc * delta)
	set_linear_velocity(Vector2(curr_vel.x, get_linear_velocity().y))

func get_state():
	if raycast_down.is_colliding():
		return "ground"
	else:
		return "air"

func set_facing():
	# Default facing
	if (ORIENTATION == "" and ORIENTATION_NEXT == "left"):
		pass
	if (ORIENTATION == "" and ORIENTATION_NEXT == "right") or \
	   (ORIENTATION == "right" and ORIENTATION_NEXT == "left") or \
	   (ORIENTATION == "left" and ORIENTATION_NEXT == "right"):
		rotate_node.set_scale(rotate_node.get_scale() * Vector2(-1, 1))

func _ready():
	raycast_down = get_node("RayCast2D")
	raycast_down.add_exception(self)
	rotate_node = get_node("rotate")

	set_fixed_process(true)
	set_applied_force(Vector2(0, extra_mass))
	PLAYER_STATE = get_state()

func _fixed_process(delta):
	PLAYER_STATE_PREV = PLAYER_STATE
	PLAYER_STATE = PLAYER_STATE_NEXT

	ORIENTATION_PREV = ORIENTATION
	ORIENTATION = ORIENTATION_NEXT

	if PLAYER_STATE == "ground":
		ground_state(delta)
	elif PLAYER_STATE == "air":
		air_state(delta)
	set_facing()
	prints(get_linear_velocity().x, move_accel*air_accel_mult)
	PLAYER_STATE_NEXT = get_state()

func air_state(delta):
	if btn_right.check() == 2:
		move(-move_speed, air_accel, delta)
		ORIENTATION_NEXT = "right"
	if btn_left.check() == 2:
		move(move_speed, air_accel, delta)
		ORIENTATION_NEXT = "left"
	if btn_left.check() == 0 and btn_right.check() == 0:
		move(0, 0, delta)
	if curr_jumps < max_jumps and btn_jump.check() == 1:
		curr_jumps += 1
		set_axis_velocity(Vector2(0, jump_force))

func ground_state(delta):
	curr_jumps = 0
	var final_speed = move_speed
	if btn_run.check() == 2:
		final_speed = run_speed
	if btn_right.check() == 2:
		move(-final_speed, move_accel, delta)
		ORIENTATION_NEXT = "right"
	if btn_left.check() == 2:
		move(final_speed, move_accel, delta)
		ORIENTATION_NEXT = "left"
	if btn_left.check() == 0 and btn_right.check() == 0:
		move(0, move_accel, delta)
	if btn_jump.check() == 1:
		curr_jumps = 1
		set_axis_velocity(Vector2(0, jump_force))