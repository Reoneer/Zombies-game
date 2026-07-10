extends CharacterBody3D

var Player
var Health
var Attack_Timer = 0.0
var Is_Dead = false

signal Zombie_Died

@export var Max_Health = 100
@export var Speed_Close = 5
@export var Speed_Far = 6
@export var Speed_Distance = 20
@export var Gravity = 9.8

@export var Damage = 13 # damage dealt to Player
@export var Attack_Range = 1.5 # how close to start hitting
@export var Attack_Cooldown = 1.33 # seconds between hits
@onready var Nav_Agent = $NavigationAgent3D


func Die():
	Is_Dead = true
	if Player:
		Player.Add_Score(100)
	Zombie_Died.emit()
	queue_free()  # removes the zombie from the scene


func Take_Damage(amount):
	Health -= amount
	if Player:
		Player.Add_Score(10) # Not sure if i want to keep this yet
	if Health <= 0: # Self explanitory. If health is less than or equals to 0, Die.
		Die()


func _ready():
	Player = get_tree().get_first_node_in_group("Player") # Find Player
	Health = Max_Health

func _physics_process (delta):
	if not Player:
		return
	if Is_Dead:
		return

	# Navigate towards Player
	Nav_Agent.target_position = Player.global_position

	var Distance = global_position.distance_to(Player.global_position)
	var Speed = Speed_Far if Distance > Speed_Distance else Speed_Close

# Deal Damage when close enough
	Attack_Timer -= delta
	if Distance <= Attack_Range and Attack_Timer <= 0.0:
		Player.Take_Damage(Damage)
		Attack_Timer = Attack_Cooldown

	var Next_Pos = Nav_Agent.get_next_path_position()
	var Direction = (Next_Pos - global_position).normalized()

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0

	velocity.x = Direction.x * Speed
	velocity.z = Direction.z * Speed

	move_and_slide()
