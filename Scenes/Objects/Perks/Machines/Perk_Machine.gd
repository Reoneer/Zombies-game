extends Area3D

@export var Perk : Perk_Data

@onready var Perk_Label = $Label3D

var Player_Nearby = false
var Player_Ref = null


# Called when the node enters the scene tree for the first time.
func _ready():
	Perk_Label.visible = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Player_Nearby = true
		Player_Ref = body
		var Interact = InputMap.action_get_events("Interact")[0].as_text().replace(" - Physical", "")
		Perk_Label.text = Perk.Perk_Name + "\n" + str(Perk.Perk_Cost) + " pts\nPress " + Interact + " to buy"
		Perk_Label.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Player_Nearby = false
		Player_Ref = null
		Perk_Label.visible = false


func _process(_delta):
	if Player_Nearby and Input.is_action_just_pressed("Interact"):
		if Player_Ref.Score >= Perk.Perk_Cost:
			if not Player_Ref.Has_Perk(Perk.Perk_Name):
				Player_Ref.Score = max(0, Player_Ref.Score - Perk.Perk_Cost)
				Player_Ref.Apply_Perk(Perk)
				Player_Ref.Add_Score(0)  # Refreshes score display, stupid but works
				print("Bought: " + Perk.Perk_Name)
			else:
				print("Already have: " + Perk.Perk_Name)
		else:
			print("Not enough points!")
			
