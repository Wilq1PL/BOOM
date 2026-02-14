extends CharacterBody3D

const BASESPEED = 6.0
const MAXSPEED = 15.0

signal deal_damage_to_player(amount)


var speed = BASESPEED

var pause = false

var canTakeDamage: = true

var sensitivity_y = 0.5

var sensitivity_x = 0.2

@onready var player: CharacterBody3D = $"."
@onready var camera: Camera3D = %Camera3D
@onready var gun: Node3D = %GunModel
@onready var marker: Marker3D = %Marker3D
@onready var cd_timer: Timer = %CooldownTimer
@onready var audio_stream_player: AudioStreamPlayer = $Camera3D / GunModel / AudioStreamPlayer
@onready var i_frames_timer: Timer = $IFramesTimer
@onready var b_hop_timer: Timer = %BHopTimer
@onready var reticle: TextureRect = %Reticle
@onready var spd_label: Label = %SpdLabel


func _ready():
    spd_label.hide()
    reticle.hide()
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _unhandled_input(event):
    if pause == true:
        pass
    else:
        if event is InputEventMouseMotion:

            rotation_degrees.y -= event.relative.x * sensitivity_y

            camera.rotation_degrees.x -= event.relative.y * sensitivity_x
            camera.rotation_degrees.x = clamp(
                camera.rotation_degrees.x, -80.0, 80
                )

    if event.is_action_pressed("escape"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        Engine.time_scale = 0.0
        if pause == false:
            pause = true
        else:
            get_tree().quit()


    elif event.is_action_pressed("shoot"):
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        pause = false
        Engine.time_scale = 1.0

func _physics_process(delta):

    var inputDirection2D = Input.get_vector(
        "move_left", "move_right", "move_forward", "move_back"
    )
    var inputDirection3D = Vector3(
        inputDirection2D.x, 0.0, inputDirection2D.y
    )
    var direction = transform.basis * inputDirection3D
    
    if is_on_floor() and b_hop_timer.is_stopped() == true:
        speed = BASESPEED
    else:
        pass
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed

    velocity.y -= 25.0 * delta
    if Input.is_action_just_pressed("jump") and is_on_floor():
        if b_hop_timer.is_stopped() == false and speed <= MAXSPEED:
            speed += 0.5
        spd_label.text = "Max speed: " + str(speed) + "m/s"
        velocity.y = 8.5
        b_hop_timer.start()
    if b_hop_timer.is_stopped():
        speed = BASESPEED


    move_and_slide()

    if Input.is_action_pressed("shoot") and cd_timer.is_stopped():
        shoot_bullet()


func shoot_bullet():
    const BULLET = preload("uid://xakwmh0pdysu")
    var newBullet = BULLET.instantiate()
    audio_stream_player.play()
    gun.recoil()
    marker.add_child(newBullet)


    newBullet.global_transform = marker.global_transform

    cd_timer.start()


func try_take_damage(amount: int):
    if canTakeDamage == false:
        return  
    else:
        velocity.y = 10.0
        deal_damage_to_player.emit(amount)
        speed = BASESPEED
        spd_label.text = "Max speed: " + str(speed) + "m/s"
        canTakeDamage = false
        i_frames_timer.start()


func _on_i_frames_timer_timeout() -> void :
    canTakeDamage = true




func _on_game_player_died() -> void:
    reticle.hide()


func _on_game_start_game() -> void:
    spd_label.show()
    reticle.show()
