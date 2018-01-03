extends RigidBody2D

var input_states = preload("res://scripts/input_states.gd")

var btn_right = input_states.new("btn_right")
var btn_left = input_states.new("btn_left")
var btn_jump = input_states.new("btn_jump")

export var move_speed = 400
export var move_accel = 5
export var extra_mass = 300
export var jump_force = -500
export var max_jumps = 1
var curr_jumps = 0
var curr_vel = Vector2(0, 0)
var raycast_down = null

func move(vel, acc, delta):
	curr_vel.x = lerp(curr_vel.x, vel, acc * delta)
	set_linear_velocity(Vector2(curr_vel.x, get_linear_velocity().y))

func on_ground():
	if raycast_down.is_colliding():
		return true
	else:
		return false

func _ready():
	raycast_down = get_node("RayCast2D")
	raycast_down.add_exception(self)
	set_fixed_process(true)
	set_applied_force(Vector2(0, extra_mass))

func _fixed_process(delta):
	if btn_right.check() == 2:
		move(-move_speed, move_accel, delta)
	if btn_left.check() == 2:
		move(move_speed, move_accel, delta)
	if btn_left.check() == 0 and btn_right.check() == 0:
		move(0, move_accel, delta)

	if on_ground():
		curr_jumps = 0
		if btn_jump.check() == 1:
			curr_jumps = 1
			set_axis_velocity(Vector2(0, jump_force))
	elif btn_jump.check() == 1 and curr_jumps < max_jumps:
		print("Double jump!")
		curr_jumps = curr_jumps + 1
		set_axis_velocity(Vector2(0, jump_force))