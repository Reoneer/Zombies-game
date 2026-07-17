extends Resource
class_name Gun_Data

@export var Gun_Name = "Pistol" # Global gun name to be shown
@export var Gun_Damage = 25 # Damage per "Pellet" or bullet
@export var Gun_Fire_Rate = 0.5 # In seconds
@export var Automatic_Gun = false # If you can hold Shoot or not
@export var Gun_Pellets = 1 # Litterally only here for shotguns, might work for grenades later too
@export var Gun_Max_Ammo = 12 # How much a mag can hold
@export var Gun_Spread = 0.01 # Little randomness to where the shots land, keep real low. like 0.05 or below
@export var Gun_Reload_Time = 1.5 # Seconds to reload
@export var Gun_Max_Reserve = 90  # max reserve ammo
@export var Gun_Cost = 1500 # Cost to buy the gun from wall buys
@export var Ammo_Cost = 500 # The cost of ammo (Default i just keep at 1/3 Gun_Cost)
