extends CharacterBody3D

# ---| CONSTANTS |---

const BASESPEED = 6.0
const MAXSPEED = 15.0
const BASECDTIME = 0.15

# ---| SIGNALS |---

signal deal_damage_to_player(amount)
signal paused()
signal unpaused()

# ---| VARIABLES |---

var speed = BASESPEED
var pause = false
var canTakeDamage: = true
var sensitivity_y = 0.5
var sensitivity_x = 0.2
var power_upped := false
var player_died := false

# ---| NODES |---

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
@onready var puptimer: Timer = %Poweruptimer
@onready var puplabel: Label = %Puplabel
@onready var gplabel: Label = %Gamepausedlabel

# ---| FUNCTIONS |---

func _ready():
    cd_timer.wait_time = 0.15
    spd_label.hide()
    reticle.hide()
    puplabel.hide()
    gplabel.hide()
    
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
func _unhandled_input(event):
    
# ---| PAUSING |---

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
        if player_died:
            get_tree().quit()
        Engine.time_scale = 0.0
        if pause == false:
            pause = true
            gplabel.show()
            paused.emit()
        else:
            get_tree().quit()


    elif event.is_action_pressed("shoot") and player_died == false:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        pause = false
        unpaused.emit()
        gplabel.hide()
        Engine.time_scale = 1.0

# ---| JUST FOR DEBUG |---

    elif event.is_action_pressed("kys"):
        deal_damage_to_player.emit(9999)


func _process(delta: float) -> void:
    
# ---| POWER UP LABEL UPDATING |---

    puplabel.set_text("Power up time left: " + str(snapped(puptimer.time_left, 0.1))  + "s")
    
func _physics_process(delta):
    
# ---| MOVEMENT |---
    
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
        velocity.y = 8.5
        b_hop_timer.start()
    if b_hop_timer.is_stopped():
        speed = BASESPEED


    move_and_slide()

# ---| SHOOTING |---

    if Input.is_action_pressed("shoot") and cd_timer.is_stopped():
        if power_upped:
            shoot_bullet(true)
        else:
            shoot_bullet(false)
        

func shoot_bullet(poweruped: bool):
    const BULLET = preload("uid://xakwmh0pdysu")
    var newBullet = BULLET.instantiate()
    audio_stream_player.play()
    gun.recoil()
    #print(poweruped)
    if not poweruped:
        marker.rotation_degrees = Vector3(0,0,0)
        marker.add_child(newBullet)
    else:
        marker.add_child(newBullet)
        marker.add_child(newBullet)
        marker.add_child(newBullet)
        marker.rotation_degrees = Vector3(
            randf_range(-5.0, 5.0), randf_range(-5.0, 5.0), randf_range(-5.0, 5.0)
            )
        
    newBullet.global_transform = marker.global_transform

    cd_timer.start()


func try_take_damage(amount: int):
    
# ---| DAMAGING PLAYER |---

    if canTakeDamage == false:
        return  
    else:
        velocity.y = 10.0
        deal_damage_to_player.emit(amount)
        speed = BASESPEED
        canTakeDamage = false
        i_frames_timer.start()

func _on_i_frames_timer_timeout() -> void :
    canTakeDamage = true

func _on_game_player_died() -> void:
    reticle.hide()
    puplabel.hide()
    spd_label.hide()
    player_died = true

func _on_game_start_game() -> void:
    spd_label.show()
    reticle.show()
    puplabel.show()

func _on_powerup_orb_collected() -> void:
    
# ---| POWERUP |---
    
    cd_timer.wait_time = BASECDTIME - 0.05
    power_upped = true  
    puptimer.start()


func _on_poweruptimer_timeout() -> void:
    power_upped = false
    cd_timer.wait_time = BASECDTIME


func _on_game_player_fell() -> void:
    
# ---| PLAYER FELL (just as the name suggests) |---
    
    velocity.y += 45.5
    deal_damage_to_player.emit(2)
