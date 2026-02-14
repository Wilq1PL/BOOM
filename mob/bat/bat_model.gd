extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void :
    animation_tree.active = true

func hurt():
    animation_tree.set(
    "parameters/OneShot/request", 
    AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE, 
)

func died():
    animation_tree.active = false
    animation_player.play("RESET")
