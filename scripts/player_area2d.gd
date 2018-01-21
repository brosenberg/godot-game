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

var ORIENTATION_PREV = ""
var ORIENTATION = ""
var ORIENTATION_NEXT = ""

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
        PLAYER_STATE = "ground"
        return "down"
    else:
        return "up"

# Aligns body1 downwards on top of body2
func align_down(body1, body2):
    var body1_corners = get_corners(body1)
    var body2_corners = get_corners(body2)
    # Let's prematurely optimize a body1.get_global_pos() out of here and use
    # the one we already did in get_corners(body1)
    var new_pos = Vector2(body1_corners[0]+body1_corners[4],
                          body2_corners[2]-body1_corners[5])
    prints("Moving to", new_pos)
    body1.set_global_pos(new_pos)

# This will shuffle the player around if there's multiple conflicting
# collisions. This should probably check to see if it's moving the player
# around cyclically and if so, punt them to somewhere safe.
# THIS IS HOW WE GET ZIPS
# Or just kill them. It worked for Mega Man 3+
func check_collision():
    var bodies = get_overlapping_bodies()
    var mycoll = get_node("CollisionShape2D")
    if bodies.size():
        for body in bodies:
            var collision_node = body.get_node("CollisionShape2D")
            var collision = collision_node.get_shape().collide_and_get_contacts(
                collision_node.get_global_transform(),
                mycoll.get_shape(),
                mycoll.get_global_transform()
            )
            if collision.size() == 2:
                print("Angle collision")
                vertical_collide(collision)
            elif collision.size() == 4:
                prints(collision[0]-collision[1])
                if collision[0][0] == collision[1][0]:
                    if vertical_collide(collision) == "down":
                        align_down(self, body)
                if collision[0][1] == collision[1][1]:
                    prints("Horizontal collision")
                    prints(collision)
        return true
    else:
        return false

func _ready():
    rotate_node = get_node("rotate")

    set_fixed_process(true)

func _fixed_process(delta):
    PLAYER_STATE_PREV = PLAYER_STATE
    PLAYER_STATE = PLAYER_STATE_NEXT

    ORIENTATION_PREV = ORIENTATION
    ORIENTATION = ORIENTATION_NEXT

    ground_state(delta)
#    if PLAYER_STATE == "ground":
#        ground_state(delta)
#    elif PLAYER_STATE == "air":
#        air_state(delta)
    set_facing()
    #PLAYER_STATE_NEXT = get_state()

func move(vector, delta):
    vector.x *= delta
    vector.y *= delta
    global_translate(vector)

func ground_state(delta):
    var movement = Vector2(0, 0)
    var speed = 300

    if PLAYER_STATE == "air":
        movement.y = 1900

    if btn_run.check() == 2:
        speed = 500

    if btn_right.check() == 2:
        movement.x = -speed
        ORIENTATION_NEXT = "right"
    elif btn_left.check() == 2:
        movement.x = speed
        ORIENTATION_NEXT = "left"
    if btn_left.check() == 0 and btn_right.check() == 0:
        pass

    if btn_jump.check() == 2:
        movement.y = -200

    if not check_collision():
        move(movement, delta)
