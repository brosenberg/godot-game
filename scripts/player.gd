extends RigidBody2D

var btn_right = Input.is_action_pressed("btn_right")
var btn_left = Input.is_action_pressed("btn_left")
var btn_jump = Input.is_action_pressed("btn_jump")

export var move_speed = 200
export var move_accel = 5
var curr_vel = Vector2(0, 0)

func move(vel, acc, delta):
	curr_vel.x = lerp(curr_vel.x, vel, acc * delta)
	set_linear_velocity(Vector2(curr_vel.x, get_linear_velocity().y))

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	btn_right = Input.is_action_pressed("btn_right")
	btn_left = Input.is_action_pressed("btn_left")
	btn_jump = Input.is_action_pressed("btn_jump")
	prints(get_linear_velocity().y, get_pos().y)
	if btn_right == true:
		move(-move_speed, move_accel, delta)
	if btn_left == true:
		move(move_speed, move_accel, delta)
	if btn_left == false and btn_right == false:
		move(0, move_accel, delta)
