extends CharacterBody3D


@onready var HEAD = $head
var CURRENT_SPEED = 5.0
const CROUCHING_SPEED = 2.0
const WALKING_SPEED = 5.0
const SPRINTING_SPEED = 8.0
const MOUSE_SENS = 0.25


var LERP_SPEED = 40.0
var DIRECTION = Vector3.ZERO
var CROUCHING_HEIGHT = 0.3

const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))
		HEAD.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENS))
		HEAD.rotation.x = clamp(HEAD.rotation.x,deg_to_rad(-85),deg_to_rad(89))
func _physics_process(delta):
	if Input.is_action_pressed("crouch"):
		CURRENT_SPEED = CROUCHING_SPEED
		HEAD.position.y = CROUCHING_HEIGHT
	else:
		HEAD.position.y = 1.8
		if Input.is_action_pressed("sprint"):
			CURRENT_SPEED = SPRINTING_SPEED
		else: 
			CURRENT_SPEED = WALKING_SPEED

	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = lerp(DIRECTION,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*LERP_SPEED)
	if direction:
		velocity.x = direction.x * CURRENT_SPEED
		velocity.z = direction.z * CURRENT_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, CURRENT_SPEED)
		velocity.z = move_toward(velocity.z, 0, CURRENT_SPEED)

	move_and_slide()
