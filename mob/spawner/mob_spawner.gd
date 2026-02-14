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
    timer.wait_time = randf_range(3.74, 4.25)
