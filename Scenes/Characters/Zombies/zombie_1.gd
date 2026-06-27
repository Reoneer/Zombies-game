extends CharacterBody3D

var player
var Health
var Attack_Timer

@export var Max_Health = 100
@export var Speed_Close = 5
@export var Speed_Far = 6
@export var Speed_Distance = 20
@export var Gravity = 9.8
@export var Damage = 13		# damage dealt to player
@export var Attack_Range = 1.5		# how close to start hitting
@export var Attack_Cooldown = 1.0		# seconds between hits
@onready var Nav_Agent = $NavigationAgent3D

func take_damage(amount):
	Health -= amount
	if Health <= 0: # Self explanitory. If health is less than or equals to 0, Die.
		Die()

func Die():
	queue_free()  # removes the zombie from the scene

func _ready():
	player = get_tree().get_first_node_in_group("player") # Find player

func _physics_process (delta):
	if not player:
		return

	# Navigate towards player
	Nav_Agent.target_position = player.global_position

	var Distance = global_position.distance_to(player.global_position)
	var Speed = Speed_Far if Distance > Speed_Distance else Speed_Close

# Deal Damage when close enough
	Attack_Timer = delta
	if Distance <= Attack_Range and Attack_Timer <= 0.0:
		player.take_damage(Damage)
		Attack_Timer = Attack_Cooldown

	var next_pos = Nav_Agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0

	velocity.x = direction.x * Speed
	velocity.z = direction.z * Speed

	move_and_slide()
