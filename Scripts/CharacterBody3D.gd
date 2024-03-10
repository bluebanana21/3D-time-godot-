extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var SENSITIVITY = 0.03

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Bullets
var bullet = load("res://Scenes/bullet.tscn")
var instance

#camera variables
@onready var head := $Head
@onready var eyes := $Head/Eyes
@onready var camera := $Head/Eyes/Camera3D
@onready var gun_barrel = $Head/Eyes/Camera3D/Rifle

#Head bobbing vars
#const Head_bobbing_sprinting_speed = 22.0
#const Head_bobbing_walking_speed = 14.0
#
#const head_bobing_sprinting_intensity = 0.2
#const head_bobing_walking_intensity = 0.1
#
#var head_bobbing_vector = Vector2.ZERO
#var head_bobbing_index = 0.0
#var head_bobbing_current_intensity = 0.0

#removes mouse cursor
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


#Camera controls
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		
		#Limits camera movement vertically
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(0), deg_to_rad(0))
	
	#Checking shooting input responsiveness


func _physics_process(delta):
	# Add the gravity.
	#if not is_on_floor():
		#velocity.y -= gravity * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	#Head bobbing logic
	#if input_dir != Vector2.ZERO:
		#head_bobbing_current_intensity = head_bobing_walking_intensity
		#head_bobbing_index += Head_bobbing_walking_speed * delta
	#
	#if is_on_floor() && input_dir != Vector2.ZERO:
		#head_bobbing_vector.y = sin(head_bobbing_index)
		#head_bobbing_vector.x = sin(head_bobbing_index / 2) + 0.5
		
		#eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity / 2.0), delta*lerp)
	
	if Input.is_action_pressed("Shoot"):
		instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(instance)
	
	move_and_slide()
