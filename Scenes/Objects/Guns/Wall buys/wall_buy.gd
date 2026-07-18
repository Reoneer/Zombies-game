extends Area3D

@export var Gun : Gun_Data
@onready var Buy_Label = $Label3D
@onready var Gun_Model = $Gun_Mesh

var Player_Nearby = false
var Player_Ref = null
var Has_Gun = false
var Gun_Index = 0

var Interact = InputMap.action_get_events("Interact")[0].as_text().replace(" - Physical", "")

func _ready():
	Buy_Label.visible = false
	Gun_Model = Gun.Gun_Model

func _on_body_entered(body):
	if body.is_in_group("Player"):
		Player_Nearby = true
		Player_Ref = body
		if Has_Gun:
			Buy_Label.text = Gun.Gun_Name + " ammo" + "\n" + str(Gun.Ammo_Cost) + " pts\nPress " + Interact + " to restock ammo"
			Buy_Label.visible = true
		if not Has_Gun:
			Buy_Label.text = Gun.Gun_Name  + "\n" + str(Gun.Gun_Cost) + " pts\nPress " + Interact + " to buy"
			Buy_Label.visible = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		Player_Nearby = false
		Player_Ref = null
		Buy_Label.visible = false


func _process(_delta):
	if Player_Nearby and Input.is_action_just_pressed("Interact"):
		
		# Check if player already owns this gun
		for i in range(Player_Ref.Inventory.size()):
			if Player_Ref.Inventory[i].Gun_Name == Gun.Gun_Name:
				Has_Gun = true
				Gun_Index = i
				break

		if not Has_Gun:
			if Player_Ref.Score >= Gun.Gun_Cost:
				Player_Ref.Score -= Gun.Gun_Cost
				Player_Ref.Pickup_Gun(Gun)
				Has_Gun = true
				Buy_Label.text = Gun.Gun_Name + " ammo" + "\n" + str(Gun.Ammo_Cost) + " pts\nPress " + Interact + " to restock ammo"
				Player_Ref.Add_Score(0)
				print("Bought: " + Gun.Gun_Name)
			else:
				print("Not enough points")
		else:
			if Player_Ref.Score >= Gun.Ammo_Cost:
				Player_Ref.Gun_Reserve[Gun_Index] = Gun.Gun_Max_Reserve
				Player_Ref.Score -= Gun.Ammo_Cost
				Player_Ref.Add_Score(0)
				print("Restocked: " + Gun.Gun_Name)
			else:
				print("Not enough points")
