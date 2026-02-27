extends Node3D

signal orb_collected()

@onready var powerup: Node3D = %Powerup
@onready var player: CharacterBody3D = %Player
@onready var area_3d: Area3D = $Area3D
@onready var timer: Timer = $Timer

const posFirst = Vector3(8.5, 1.0, 6.0)
const posSecond = Vector3(21.0, 1.0, 6.2)
const posThird = Vector3(17.5, 1.0, -7.5)
const posFourth = Vector3(8.0, 1.0, -6.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    spawn_the_orb()
    
    
    
func spawn_the_orb():
    powerup.show()
    var posRandom = snapped(randf_range(0, 4), 1)
    print(posRandom)
    if posRandom == 1:
        powerup.global_position = posFirst
        
    elif posRandom == 2:
        powerup.global_position = posSecond
        
    elif posRandom == 3:
        powerup.global_position = posThird
        
    elif posRandom == 4:
        powerup.global_position = posFourth


func _on_area_3d_body_entered(body: Node3D) -> void:
    orb_collected.emit()
    powerup.hide()
    timer.start()


func _on_timer_timeout() -> void:
    spawn_the_orb()
