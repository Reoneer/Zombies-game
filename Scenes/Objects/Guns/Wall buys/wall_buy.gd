extends Area3D

@export var Gun : Gun_Data
@export var Gun_Cost = 1500

@onready var Buy_Label = $Label3D

var Player_Nearby = false
var Player_Ref = null

func _ready():
	Buy_Label.visible = false

func _on_body_entered(body):
	if body.is_in_group("Player"):
		Player_Nearby = true
		Player_Ref = body
		var Interact = InputMap.action_get_events("Interact")[0].as_text().replace(" - Physical", "")
		Buy_Label.text = Gun.Gun_Name + "\n" + str(Gun_Cost) + " pts\nPress " + Interact + " to buy"
		Buy_Label.visible = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		Player_Nearby = false
		Player_Ref = null
		Buy_Label.visible = false

func _process(_delta):
	if Player_Nearby and Input.is_action_just_pressed("Interact"):
		if Player_Ref.Score >= Gun_Cost:
			Player_Ref.Score -= Gun_Cost
			Player_Ref.Score = max(0, Player_Ref.Score - Gun_Cost)
			Player_Ref.Pickup_Gun(Gun)
			Player_Ref.Add_Score(0)  # Refresh score display
		else:
			print("Not enough points!")
