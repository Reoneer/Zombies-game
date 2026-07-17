extends Marker3D

@export var Player_Scene : PackedScene

func _ready():
	var Player = Player_Scene.instantiate()
	get_parent().add_child.call_deferred(Player)
	await get_tree().process_frame
	Player.global_position = global_position
