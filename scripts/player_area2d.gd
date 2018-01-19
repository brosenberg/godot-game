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
var PLAYER_STATE_NEXT = ""

var ORIENTATION_PREV = ""
var ORIENTATION = ""
var ORIENTATION_NEXT = ""

func get_state():
    return "air"
    #if raycast_down.is_colliding():
    #    return "ground"
    #else:
    #    return "air"

func set_facing():
    # Default facing
    if (ORIENTATION == "" and ORIENTATION_NEXT == "left"):
        pass
    if (ORIENTATION == "" and ORIENTATION_NEXT == "right") or \
       (ORIENTATION == "right" and ORIENTATION_NEXT == "left") or \
       (ORIENTATION == "left" and ORIENTATION_NEXT == "right"):
        rotate_node.set_scale(rotate_node.get_scale() * Vector2(-1, 1))

# Returns [ left, right, top, bottom ]
func get_edges(body):
    var pos = body.get_global_pos()
    var rect = body.get_node("CollisionShape2D").get_item_rect()
    print(rect)
    return [pos.x, (pos.x + rect.size[0]),
            pos.y, (pos.y - rect.size[1])]

func check_collision(delta):
    var bodies = get_overlapping_bodies()
    var mycoll = get_node("CollisionShape2D")
    if bodies.size():
        for body in bodies:
            var coll = body.get_node("CollisionShape2D")
            #var shape = coll.get_shape()
            var collision = coll.get_shape().collide_and_get_contacts(
                coll.get_global_transform(),
                mycoll.get_shape(),
                mycoll.get_global_transform()
            )
            if collision[0][0] == collision[1][0]:
                prints("Vertical collision")
            if collision[0][1] == collision[1][1]:
                prints("Horizontal collision")
        return true
    else:
        return false

# Should return [x, y].
# If x = 1 right collision, x = -1 left collision, x = 0 no horiz collision
# If y = 1 top collision, y = -1 bottom collision, y = 0 no vert collision
func _check_collision(delta):
    var bodies = get_overlapping_bodies()
    var myedges = get_edges(self)
    if bodies.size():
        for body in bodies:
            #prints("Colliding with object at", rect.size[0])
            var edges = get_edges(body)
            if edges[0] < myedges[1]:
                prints("Colliding on right", myedges, edges)
            if edges[1] > myedges[0]:
                prints("Colliding on left", myedges, edges)
            if edges[3] > myedges[2]:
                prints("Colliding on top", myedges, edges)
            if edges[2] < myedges[3]:
                prints("Colliding on bottom", myedges, edges)
        return true
    else:
        return false

func _ready():
    rotate_node = get_node("rotate")
    #collide_node = get_node("player_kinematic")

    set_fixed_process(true)
    PLAYER_STATE = get_state()

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
    PLAYER_STATE_NEXT = get_state()

func move(vector, delta):
    vector.x *= delta
    vector.y *= delta
    global_translate(vector)

func ground_state(delta):
    var movement = Vector2(0, 0)
    var speed = 300

    if PLAYER_STATE == "air":
        movement.y = 400

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

    if not check_collision(delta):
        move(movement, delta)
