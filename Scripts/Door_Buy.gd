extends Area3D

var Player_Nearby = false
var Player_Ref = null
@export var Door_Cost = 750

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Player_Nearby = true
		Player_Ref = body

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Player_Nearby = false
		Player_Ref = null


func _process(_delta):
	if Player_Nearby and Input.is_action_just_pressed("Interact"):
		if Player_Ref.Score >= Door_Cost:
			Player_Ref.Score = max(0, Player_Ref.Score - Door_Cost)
			Player_Ref.Add_Score(0)
			Buy()
		else:
			print("Not enough points!")

func Buy():
	queue_free()
