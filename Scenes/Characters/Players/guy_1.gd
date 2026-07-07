extends CharacterBody3D

var CurrentSpeed = 5.0
var Walk_Speed = 6.66666666667 :
	set(value):
			Walk_Speed = value
			Run_Speed = Walk_Speed * 1.5
var Run_Speed = Walk_Speed * 1.5
var Jump_Velocity = 5

var SENSITIVITY = 0.008

#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
var BASE_FOV = 90.0
const FOV_CHANGE = 1.5

var gravity = 9.8

<<<<<<< Updated upstream
@onready var head = $MeshInstance3D
@onready var camera = $MeshInstance3D/Camera3D
=======
var Gun_Ammo = [0,0]

@onready var FPS_Label = $Player_HUD/FPS_Label

@onready var Gun_1_Name = $Player_HUD/Gun_UI/Gun_1/Gun_1_Name
@onready var Gun_1_Ammo = $Player_HUD/Gun_UI/Gun_1/Gun_1_Ammo
@onready var Gun_2_Name = $Player_HUD/Gun_UI/Gun_2/Gun_2_Name
@onready var Gun_2_Ammo = $Player_HUD/Gun_UI/Gun_2/Gun_2_Ammo
>>>>>>> Stashed changes

func Test():
	if Input.is_action_just_pressed("Test_1"):
		Walk_Speed += 5
	if Input.is_action_just_pressed("Test_2"):
		Walk_Speed -= 5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	Test()
<<<<<<< Updated upstream
=======
	FPS_Label.text = "FPS: " + str(Engine.get_frames_per_second())

		# Count down the shoot timer every frame
	if Shoot_Timer > 0.0:
		Shoot_Timer -= delta

	# Why: auto rifles fire while held, others fire on click
	var Gun = Get_Current_Gun()
	if Gun:
		if Gun.Automaitc_Gun and Input.is_action_pressed("shoot"):
			Shoot()
		elif not Gun.Automaitc_Gun and Input.is_action_just_pressed("Shoot"):
			Shoot()

	# Weapon switching
	if Input.is_action_just_pressed("Gun_1"):
		Current_Gun_Index = 0
		Update_Gun_UI()
	if Input.is_action_just_pressed("Gun_2"):
		Current_Gun_Index = 1
		Update_Gun_UI()
	if Input.is_action_just_pressed("Scroll_UP"):
		Switch_Gun(1)
		Update_Gun_UI()
	if Input.is_action_just_pressed("Scroll_DOWN"):
		Switch_Gun(-1)
		Update_Gun_UI()
	
	
>>>>>>> Stashed changes
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = Jump_Velocity

	# Handle Sprint.
	if Input.is_action_pressed("Sprint"):
		CurrentSpeed = Run_Speed
	else:
		CurrentSpeed = Walk_Speed

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("Walk_R", "Walk_L", "Walk_B", "Walk_F")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * CurrentSpeed
			velocity.z = direction.z * CurrentSpeed
		else:
			velocity.x = lerp(velocity.x, direction.x * CurrentSpeed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * CurrentSpeed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * CurrentSpeed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * CurrentSpeed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, Run_Speed * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
