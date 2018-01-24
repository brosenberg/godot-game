extends Area2D

var input_states = preload("res://scripts/input_states.gd")

var btn_right = input_states.new("btn_right")
var btn_left = input_states.new("btn_left")
var btn_jump = input_states.new("btn_jump")
var btn_run = input_states.new("btn_run")

var rotate_node = null
var collide_node = null

var PLAYER_STATE_PREV = ""
var PLAYER_STATE = ""
var PLAYER_STATE_NEXT = "air"
# Maybe change to a tuple of:
# (air/ground, walk/run,boost, water/atmo)

var ORIENTATION_PREV = ""
var ORIENTATION = ""
var ORIENTATION_NEXT = ""

var movement = Vector2(0, 0)
var max_y_v = 800.0
var max_x_v = 700.0

var walk_speed = 2.8
var max_walk = 350.0

var run_speed = 3.0
var max_run = 550.0

var jump_speed = 540.0

var GRAVITY = 11

func set_facing():
    # Default facing
    if (ORIENTATION == "" and ORIENTATION_NEXT == "left"):
        pass
    if (ORIENTATION == "" and ORIENTATION_NEXT == "right") or \
       (ORIENTATION == "right" and ORIENTATION_NEXT == "left") or \
       (ORIENTATION == "left" and ORIENTATION_NEXT == "right"):
        rotate_node.set_scale(rotate_node.get_scale() * Vector2(-1, 1))

# Returns [ left_pos, right_pos, top_pos, bottom_pos, x_extent, y_extent ]
# Only works on bodies with rectangular CollisionShape2D's
func get_corners(body):
    var pos = body.get_global_pos()
    var extents = body.get_node("CollisionShape2D").get_shape().get_extents()
    return [pos.x - extents[0], pos.x + extents[0],
            pos.y - extents[1], pos.y + extents[1],
            extents[0], extents[1]]

func vertical_collide(collision):
    if collision[0][1] > get_global_pos()[1]:
        PLAYER_STATE_NEXT = "ground"
        return "down"
    else:
        return "up"

# TODO: Send this the velocity vector to determine collision direction
func horizontal_collide(collision):
    if movement.x > 0:
        return "right"
    elif movement.x < 0:
        return "left"
    elif ORIENTATION == "left":
        return "right"
    else:
        return "left"

# Aligns body1 downwards on top of body2
func align_down(body1, body2):
    var body1_corners = get_corners(body1)
    var body2_corners = get_corners(body2)
    # Let's prematurely optimize a body1.get_global_pos() out of here and use
    # the one we already did in get_corners(body1)
    var new_pos = Vector2(body1_corners[0]+body1_corners[4],
                          body2_corners[2]-body1_corners[5])
    #prints("Moving to", new_pos)
    body1.set_global_pos(new_pos)

func align_right(body1, body2):
    var body1_corners = get_corners(body1)
    var body2_corners = get_corners(body2)
    var new_pos = Vector2(body2_corners[0]-body1_corners[4],
                          body1.get_pos()[1])
    #prints("Moving to", new_pos, "Old pos", body1.get_global_pos())
    body1.set_global_pos(new_pos)

func align_left(body1, body2):
    var body1_corners = get_corners(body1)
    var body2_corners = get_corners(body2)
    var new_pos = Vector2(body2_corners[1]+body1_corners[4],
                          body1.get_pos()[1])
    #prints(body2_corners[0], body2_corners[1], body1_corners[4])
    #prints("Moving to", new_pos, "Old pos", body1.get_global_pos())
    body1.set_global_pos(new_pos)

func do_horiz_collision(body, collision):
    var self_corners = get_corners(self)
    var body_corners = get_corners(body)
    prints("-------------------------")
    prints("self_corners:", self_corners)
    prints("body_corners:", body_corners)
    prints("self.pos:", self.get_global_pos())
    prints("body.pos:", body.get_global_pos())
    prints("collision:", collision)
    prints("body.name:", body.get_name())
    if horizontal_collide(collision) == "left":
        print("colliding left")
        align_left(self, body)
    else:
        print("colliding right")
        align_right(self, body)
    prints("-------------------------")

# This will shuffle the player around if there's multiple conflicting
# collisions. This should probably check to see if it's moving the player
# around cyclically and if so, punt them to somewhere safe.
# THIS IS HOW WE GET ZIPS
# Or just kill them. It worked for Mega Man 3+
func handle_collision():
    var bodies = get_overlapping_bodies()
    var mycoll = get_node("CollisionShape2D")
    var on_ground = false
    if bodies.size():
        for body in bodies:
            var collision_node = body.get_node("CollisionShape2D")
            var collision = collision_node.get_shape().collide_and_get_contacts(
                collision_node.get_global_transform(),
                mycoll.get_shape(),
                mycoll.get_global_transform()
            )
            if collision == null:
                continue
            elif collision.size() == 2:
                print("Angle collision")
                vertical_collide(collision)
            elif collision.size() == 4:
                #if PLAYER_STATE != "ground" and collision[0][0] == collision[1][0]:
                if collision[0][0] == collision[1][0] and movement.y != 0:
                    if vertical_collide(collision) == "down":
                        align_down(self, body)
                        on_ground = true
                        prints(get_global_pos())
                if collision[0][1] == collision[1][1] and movement.x != 0:
                    do_horiz_collision(body, collision)
        if not on_ground:
            PLAYER_STATE_NEXT = "air"
        return true
    else:
        PLAYER_STATE_NEXT = "air"
        return false

func _ready():
    rotate_node = get_node("rotate")

    set_fixed_process(true)

func _fixed_process(delta):
    PLAYER_STATE_PREV = PLAYER_STATE
    PLAYER_STATE = PLAYER_STATE_NEXT

    ORIENTATION_PREV = ORIENTATION
    ORIENTATION = ORIENTATION_NEXT

    if PLAYER_STATE == "ground":
        ground_state(delta)
    elif PLAYER_STATE == "air":
        air_state(delta)
    handle_collision()
    set_facing()
    #PLAYER_STATE_NEXT = get_state()

func move(vector, delta):
    vector.x *= delta
    vector.y *= delta
    global_translate(vector)

func ground_state(delta):

    if btn_right.check() == 2:
        if ORIENTATION == "left":
            prints("Turning around", movement.x)
            movement.x = 0
        else:
            movement.x -= walk_speed
            if btn_run.check() == 2:
                movement.x -= run_speed
                if abs(movement.x) > max_run:
                    movement.x = -max_run
            elif abs(movement.x) > max_walk:
                movement.x = -max_walk
        ORIENTATION_NEXT = "right"
    elif btn_left.check() == 2:
        if ORIENTATION == "right":
            prints("Turning around", movement.x)
            movement.x = 0
        else:
            movement.x += walk_speed
            if btn_run.check() == 2:
                movement.x += run_speed
                if movement.x > max_run:
                    movement.x = max_run
            elif movement.x > max_walk:
                movement.x = max_walk
        ORIENTATION_NEXT = "left"
    elif btn_left.check() == 0 and btn_right.check() == 0 and movement.x != 0:
        prints("Slowing down", movement.x)
        movement.x *= 0.8
        if abs(movement.x) < 10:
            movement.x =0

    if btn_jump.check() == 2:
        PLAYER_STATE_NEXT = "air"
        movement.y -= jump_speed

    move(movement, delta)

func air_state(delta):
    movement.y += GRAVITY
    if movement.y > max_y_v:
        movement.y = max_y_v

    if btn_right.check() == 2:
        movement.x -= walk_speed
        if btn_run.check() == 2:
            movement.x -= run_speed
            if abs(movement.x) > max_run:
                movement.x = -max_run
        elif abs(movement.x) > max_walk:
            movement.x = -max_walk
        ORIENTATION_NEXT = "right"
    elif btn_left.check() == 2:
        movement.x += walk_speed
        if btn_run.check() == 2:
            movement.x += run_speed
            if movement.x > max_run:
                movement.x = max_run
        elif movement.x > max_walk:
            movement.x = max_walk
        ORIENTATION_NEXT = "right"

    move(movement, delta)
