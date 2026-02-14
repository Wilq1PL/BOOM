extends Node3D

signal player_died()
signal start_game()

@onready var score_label: Label = %ScoreLabel
@onready var health_label: Label = %HealthLabel
@onready var player: CharacterBody3D = %Player
@onready var game_over_label: Label = %GameOverLabel
@onready var game_over_text_label: Label = %GameOverTextLabel
@onready var ultrakool_music_player: AudioStreamPlayer = $UltrakoolMusicPlayer
@onready var labels: Node = $Labels
@onready var welcome_label: Label = $Labels/WelcomeLabel

var score = 0
var player_health = 5
var listening_for_input := false
var game_started := false

func _ready() -> void :
    Engine.time_scale = 0.0
    game_over_label.hide()
    game_over_text_label.hide()
    score_label.hide()
    health_label.hide()
    welcome_label.show()        


func _process(delta: float) -> void:
    if listening_for_input == true and Input.is_action_just_pressed("shoot"):
        get_tree().reload_current_scene.call_deferred()

func increase_score():
    score += 1
    score_label.text = ("Score: " + str(score))

func spawn_smoke(mobGlobalPos):
    const SMOKE = preload("uid://cjk3frr43yesb")
    var poof = SMOKE.instantiate()
    add_child(poof)
    poof.global_position = mobGlobalPos


func _on_mob_spawner_mob_spawned(mob: Variant) -> void :
    mob.died.connect( func on_mob_dissapeared():
        spawn_smoke(mob.global_position)
        )
    mob.add_score.connect( func on_mob_killed():
        increase_score()
        )
    spawn_smoke(mob.global_position)


func _on_killplane_body_entered(body: Node3D) -> void :
    player_health -= 2
    health_label.text = "Health: " + str(player_health)
    player.global_position = Vector3(0.0, 0.01416, 0.0)
    if player_health <= 0:
        player_died.emit()



func _on_player_deal_damage_to_player(amount: Variant) -> void :
    player_health -= amount
    print("zadano")
    health_label.text = "Health: " + str(player_health)
    if player_health <= 0:
        player_died.emit()


func _on_player_died() -> void :
    game_over_label.show()
    game_over_text_label.show()
    score_label.hide()
    health_label.hide()
    ultrakool_music_player.stop()
    game_over_text_label.text = "
    Oh no! The bats got you!\nYour Score: " + str(score) + "\nPress LMB to restart.
    "
    Engine.time_scale = 0.0
    listening_for_input = true


func _on_start_game() -> void:
    game_started = true
    game_over_label.hide()
    game_over_text_label.hide()
    score_label.show()
    health_label.show()
    ultrakool_music_player.play()
    welcome_label.hide()
    
func _unhandled_input(event: InputEvent) -> void:
        if Input.is_action_just_pressed("shoot") and game_started == false:
            start_game.emit()
        else:
            pass
