extends Node2D

@export var textures_floor:Array[Texture2D]=[]
@export var textures_wall:Array[Texture2D]=[]
@export var textures_acids:Array[Texture2D]=[]

@export var RoomBgFloor:Sprite2D
@export var RoomBgWall:Sprite2D
@export var RoomBgAcids:Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	RoomBgFloor.texture=textures_floor[randi()%textures_floor.size()]
	RoomBgWall.texture=textures_wall[randi()%textures_floor.size()]
	RoomBgAcids.texture=textures_acids[randi()%textures_floor.size()]
