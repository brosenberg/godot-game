extends RigidBody2D

var input_states = preload("res://scripts/input_states.gd")

var btn_right = input_states.new("btn_right")
var btn_left = input_states.new("btn_left")
var btn_jump = input_states.new("btn_jump")
var btn_run = input_states.new("btn_run")

export var move_speed = 400
export var move_accel = 3
export var extra_mass = 300
export var jump_force = -300
export var max_jumps = 1
export var air_accel_mult = 2/3
export var run_accel_mult = 1.5
var curr_jumps = 0
var curr_vel = Vector2(0, 0)
var raycast_down = null

var PLAYER_STATE_PREV = ""
var PLAYER_STATE = ""
var PLAYER_STATE_NEXT = ""

func move(vel, acc, delta):
	curr_vel.x = lerp(curr_vel.x, vel, acc * delta)
	set_linear_velocity(Vector2(curr_vel.x, get_linear_velocity().y))

func get_state():
	if raycast_down.is_colliding():
		return "ground"
	else:
		return "air"

func _ready():
	raycast_down = get_node("RayCast2D")
	raycast_down.add_exception(self)
	set_fixed_process(true)
	set_applied_force(Vector2(0, extra_mass))
	PLAYER_STATE = get_state()

func _fixed_process(delta):
	PLAYER_STATE_PREV = PLAYER_STATE
	PLAYER_STATE = PLAYER_STATE_NEXT
	print(PLAYER_STATE)
	if PLAYER_STATE == "ground":
		ground_state(delta)
	elif PLAYER_STATE == "air":
		air_state(delta)

	PLAYER_STATE_NEXT = get_state()

func air_state(delta):
	if btn_right.check() == 2:
		move(-move_speed, move_accel*air_accel_mult, delta)
	if btn_left.check() == 2:
		move(move_speed, move_accel*air_accel_mult, delta)
	if btn_left.check() == 0 and btn_right.check() == 0:
		move(0, move_accel, delta)
	if curr_jumps < max_jumps and btn_jump.check() == 1:
		curr_jumps += 1
		set_axis_velocity(Vector2(0, jump_force))

func ground_state(delta):
	curr_jumps = 0
	var run_mult = 1
	if btn_run.check() == 2:
		print("Running!")
		run_mult = run_accel_mult
	if btn_right.check() == 2:
		move(-move_speed*run_mult, move_accel, delta)
	if btn_left.check() == 2:
		move(move_speed*run_mult, move_accel, delta)
	if btn_left.check() == 0 and btn_right.check() == 0:
		move(0, move_accel, delta)
	if btn_jump.check() == 1:
		curr_jumps = 1
		set_axis_velocity(Vector2(0, jump_force))