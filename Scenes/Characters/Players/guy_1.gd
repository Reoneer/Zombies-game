extends CharacterBody3D

# Movement
var CurrentSpeed = 5.0
var Walk_Speed = 5.0 :
	set(value):
		Walk_Speed = value
		Run_Speed = Walk_Speed * 1.5
var Run_Speed = Walk_Speed * 1.5
var Jump_Velocity = 5
var SENSITIVITY = 0.008

# Health
@export var Max_Health = 100
var Health = 100

# Gun inventory
@export var Starter_Gun : Gun_Data
var Inventory = []
var Current_Gun_Index = 0
var Shoot_Timer = 0.0
var Gun_Ammo = [0, 0]
var Score = 0 # Not really gun related but there's not really a better place for it so it stays here for the time being
var Active_Perks = [] # same here

# Head bob
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

# FOV
var BASE_FOV = 60.0
const FOV_CHANGE = 1.5

# Node references
@onready var head = $MeshInstance3D
@onready var camera = $MeshInstance3D/Camera3D
@onready var Gun_Barrel = $MeshInstance3D/Camera3D/Gun_Barrel
@onready var Health_Bar = $Player_HUD/Health_bar
@onready var FPS_Label = $Player_HUD/FPS_Label
@onready var Gun_1_Name = $Player_HUD/Gun_UI/Gun_1/Gun_1_Name
@onready var Gun_1_Ammo = $Player_HUD/Gun_UI/Gun_1/Gun_1_Ammo
@onready var Gun_2_Name = $Player_HUD/Gun_UI/Gun_2/Gun_2_Name
@onready var Gun_2_Ammo = $Player_HUD/Gun_UI/Gun_2/Gun_2_Ammo
@onready var Score_Label = $Player_HUD/Score_Label

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Starter_Gun:
		Inventory.append(Starter_Gun)
		Gun_Ammo[0] = Starter_Gun.Gun_Max_Ammo
	Update_Gun_UI()


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))


func Add_Score(amount):
	Score = max(0, Score + amount)
	Score_Label.text = "Score: " + str(Score)


func Has_Perk(Perk_Name : String) -> bool:
	return Perk_Name in Active_Perks


func Apply_Perk(Perk : Perk_Data):
	Active_Perks.append(Perk.Perk_Name)
	
	if Perk.Health_Bonus > 0:
		Max_Health += Perk.Health_Bonus
		Health += Perk.Health_Bonus
		Health_Bar.max_value = Max_Health
		Health_Bar.value = Health
	
	if Perk.Speed_Bonus > 0:
		Walk_Speed += Perk.Speed_Bonus
	
	if Perk.Fire_Rate_Bonus > 0:
		pass

func _physics_process(delta: float):
	Test()

	# Update FPS label
	FPS_Label.text = "FPS: " + str(Engine.get_frames_per_second())

	# Count down shoot timer every frame
	if Shoot_Timer > 0.0:
		Shoot_Timer -= delta

	# Shooting
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

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = Jump_Velocity

	# Sprint
	if Input.is_action_pressed("Sprint"):
		CurrentSpeed = Run_Speed
	else:
		CurrentSpeed = Walk_Speed

	# Movement
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


func Take_Damage(amount):
	Health -= amount
	Health_Bar.value = Health
	if Health <= 0:
		Die()


func Die():
	get_tree().reload_current_scene()


func Pickup_Gun(Gun : Gun_Data):
	if Inventory.size() < 2:
		Inventory.append(Gun)
		Gun_Ammo[Inventory.size() - 1] = Gun.Gun_Max_Ammo
	else:
		Inventory[Current_Gun_Index] = Gun
		Gun_Ammo[Current_Gun_Index] = Gun.Gun_Max_Ammo
	Update_Gun_UI()


func Get_Current_Gun() -> Gun_Data:
	if Inventory.size() == 0:
		return null
	return Inventory[Current_Gun_Index]


func Shoot():
	var Gun = Get_Current_Gun()
	if not Gun:
		return
	if Shoot_Timer > 0.0:
		return
	Shoot_Timer = Gun.Gun_Fire_Rate
	if Gun_Ammo[Current_Gun_Index] <= 0:
		return
	Gun_Ammo[Current_Gun_Index] -= 1
	Update_Gun_UI()
	for i in range(Gun.Gun_Pellets):
		var Ray_Origin = Gun_Barrel.global_position
		var Spread = Vector3(
			randf_range(-Gun.Gun_Spread, Gun.Gun_Spread),
			randf_range(-Gun.Gun_Spread, Gun.Gun_Spread),
			0
		)
		
		var Ray_Direction = (camera.global_transform.basis * (Vector3.FORWARD + Spread)).normalized()
		var Ray_End = Ray_Origin + Ray_Direction * 500.0
		var Ray = PhysicsRayQueryParameters3D.create(Ray_Origin, Ray_End)
		Ray.exclude = [self]
		var Result = get_world_3d().direct_space_state.intersect_ray(Ray)
		if Result and Result.collider.has_method("Take_Damage"):
			Result.collider.Take_Damage(Gun.Gun_Damage)


func Switch_Gun(Direction : int):
	if Inventory.size() < 2:
		return
	# Why: wrapi handles negative numbers correctly unlike %
	Current_Gun_Index = wrapi(Current_Gun_Index + Direction, 0, Inventory.size())


func Update_Gun_UI():
	if Inventory.size() >= 1:
		Gun_1_Name.text = Inventory[0].Gun_Name
		Gun_1_Ammo.text = str(Gun_Ammo[0]) + " / " + str(Inventory[0].Gun_Max_Ammo)
	else:
		Gun_1_Name.text = ""
		Gun_1_Ammo.text = ""
	if Inventory.size() >= 2:
		Gun_2_Name.text = Inventory[1].Gun_Name
		Gun_2_Ammo.text = str(Gun_Ammo[1]) + " / " + str(Inventory[1].Gun_Max_Ammo)
	else:
		Gun_2_Name.text = ""
		Gun_2_Ammo.text = ""
	Gun_1_Name.modulate = Color.YELLOW if Current_Gun_Index == 0 else Color.WHITE
	Gun_2_Name.modulate = Color.YELLOW if Current_Gun_Index == 1 else Color.WHITE


func Test():
	if Input.is_action_just_pressed("Test_1"):
		Add_Score(50000)
	if Input.is_action_just_pressed("Test_2"):
		Add_Score(-50000)
