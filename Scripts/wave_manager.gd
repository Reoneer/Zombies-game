extends Node
# Zombie_Scene and Spawn_Points are for the main map scene to edit.
@export var Zombie_Scene : PackedScene
@export var Spawn_Points : Array[NodePath]
@export var Base_Zombie_Count = 6
@export var Spawn_Delay = 1

# Based things
var Current_Wave = 0
var Zombies_Remaining = 0
var Wave_Active = false
var Wave_Label
var Zombie_Label

@onready var Player = get_tree().get_first_node_in_group("Player")


var Enabled = true # only change to false for testing

func _ready(): # Instantly start a wave
	if not Enabled:
		print("Waves are not enabled.   If not testing set 'enabled' to true in wave_manager.gd") shitter
		return

	Start_Next_Wave.call_deferred()
	Find_Labels.call_deferred()



func Find_Labels():
	@warning_ignore("shadowed_variable")
	var Player = get_tree().get_first_node_in_group("Player")
	if Player:
		Wave_Label = Player.get_node("Player_HUD/Wave_Label")
		Zombie_Label = Player.get_node("Player_HUD/Zombies_Label")
		Update_HUD()
	else:
		await get_tree().process_frame
		Find_Labels()

func _process(_delta): 
	if not Wave_Active: # if not doing a wave, do nothing. Why would you not be, but is here for safety
		return

func Start_Next_Wave():
	if Wave_Active:
		return
	Current_Wave += 1
	@warning_ignore("shadowed_variable")
	var Player = get_tree().get_first_node_in_group("Player")
	if Current_Wave >= 2 and Player:
		Player.Add_Score(250)
	var Zombie_Count = int(Base_Zombie_Count + (Current_Wave - 1) * 1.5)
	Zombies_Remaining = Zombie_Count # Reset to above.
	Wave_Active = true
	if Wave_Label and Zombie_Label:
		Update_HUD()

	for i in range(Zombie_Count):
		Spawn_Zombie()
		if i < Zombie_Count - 1:
			await get_tree().create_timer(Spawn_Delay).timeout


func Spawn_Zombie():
	if Spawn_Points.size() == 0: # If no spawns are set, dont spawn or try anything.
		return
# Pretty much, Choose randomly from spawn points and spawn a zombie there
	var Random_Point = get_node(Spawn_Points[randi() % Spawn_Points.size()])
	if not Random_Point:
		print("ERROR: Spawn point is null!")
		return
	var Zombie = Zombie_Scene.instantiate()
	get_parent().add_child(Zombie)
	Zombie.global_position = Random_Point.global_position
	Zombie.connect("Zombie_Died", _on_Zombie_Died) # connects to signal in zombie_1.gd.

func _on_Zombie_Died():
	Zombies_Remaining -= 1 # When a zombie dies, remove one from the zombies remaining count.
	Update_HUD()
	if Zombies_Remaining == 0: # When all zombies are dead, wait 3 seconds then start new wave.
		Wave_Active = false
		await get_tree().create_timer(15.0).timeout
		Start_Next_Wave()

func Update_HUD():
	Wave_Label.text = "Wave: " + str(Current_Wave)
	Zombie_Label.text = "Zombies: " + str(Zombies_Remaining)
