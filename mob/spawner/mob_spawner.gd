extends Node3D

signal mob_spawned(mob)

@export var mob_to_spawn: PackedScene = null

@onready var marker: Marker3D = $Marker3D
@onready var timer: Timer = $Timer
func _ready() -> void:
    pass

func _on_timer_timeout() -> void :
    var new_mob = mob_to_spawn.instantiate()
    add_child(new_mob)
    new_mob.global_position = marker.global_position
    new_mob.set_global_rotation_degrees(Vector3(0.0, 180.0, 0.0))
    mob_spawned.emit(new_mob)


func _on_game_make_game_harder() -> void:
    if timer.wait_time >= 0.75:
        timer.wait_time -= 0.5
