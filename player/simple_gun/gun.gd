extends Node3D

@export var side_position: Vector3 = Vector3(0.3, -0.15, -0.4)
@export var center_position: Vector3 = Vector3(0.0, -0.15, -0.4)
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_centered: = false

func _ready():
    position = side_position

func _process(_delta):
    if Input.is_action_just_pressed("doom"):
        is_centered = !is_centered
        position = center_position if is_centered else side_position

func recoil():
    animation_player.play("recoil")
