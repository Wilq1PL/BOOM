extends RigidBody3D

signal died()
signal add_score()


var player_inside: = false
var speed = randf_range(3.0, 6.0)
var health = randf_range(2.0, 4.0)

@onready var bat_model: Node3D = %bat_model
@onready var player: CharacterBody3D = get_node("/root/Game/Player")
@onready var puff_timer: Timer = %PuffTimer
@onready var hurt_player: AudioStreamPlayer3D = %HurtPlayer
@onready var died_player: AudioStreamPlayer3D = %DiedPlayer
@onready var area_3d: Area3D = $Area3D


const MOB_TAKE_DAMAGE = preload("uid://bx3idpeigglls")

func _ready() -> void :
    axis_lock_linear_y = true
    lock_rotation = true

func _physics_process(_delta: float) -> void :
    var direction = global_position.direction_to(player.global_position)
    direction.y = 0.0
    linear_velocity = direction * speed
    bat_model.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP)
    if player_inside == false:
        return
    else:
        print("trying to take damage")
        player.try_take_damage(1)



func take_damage():
    if not health <= 0:
        hurt_player.play()
    bat_model.hurt()
    health -= 1

    if health <= 0:
        died_player.play()
        set_physics_process(false)
        gravity_scale = 1.0
        var direction = -1.0 * global_position.direction_to(player.global_position)
        var randomUpwardForce = Vector3.UP * randf_range(1.0, 5.0)
        apply_central_impulse(direction * 6.5 + randomUpwardForce)
        if health >= -1:
            puff_timer.start()
            add_score.emit()
            bat_model.died()
        axis_lock_linear_y = false
        lock_rotation = false


func _on_timer_timeout() -> void :
    queue_free()
    died.emit()

func _on_area_3d_body_entered(body):
    if body.name == player.name:

        player_inside = true

func _on_area_3d_body_exited(body):
    if body.name == player.name:

        player_inside = false
