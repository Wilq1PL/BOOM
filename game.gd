extends Node3D

# ---| CONSTANTS |---
const myTopScore = 59

# ---| SIGNALS |---

signal player_died()
signal start_game()
signal player_fell()
signal make_game_harder()

# ---| VARIABLES |---

var playerScore = 0
var player_health = 5
var listening_for_input := false
var game_started := false
var name_inputted := false
var scoreFile = "user://scores.nyb"
var labels_state = 0 # Game just powerd on, 1 Game started, 2 Game over
var tempScore = 0

# ---| NODES |---

@onready var score_label: Label = %ScoreLabel
@onready var health_label: Label = %HealthLabel
@onready var player: CharacterBody3D = %Player
@onready var game_over_label: Label = %GameOverLabel
@onready var game_over_text_label: Label = %GameOverTextLabel
@onready var labels: Node = $Labels
@onready var welcome_label: Label = $Labels/WelcomeLabel
@onready var leader_label: Label = %LeaderLabel
@onready var name_inputter: LineEdit = %NameInputter
@onready var timer: Timer = $Labels/NameInputter/Timer
@onready var blood_blur_1: TextureRect = %BloodBlur1
@onready var blood_timer: Timer = %BloodTimer
@onready var heart_green: TextureRect = %HeartGreen
@onready var vignette: TextureRect = %Vignette
@onready var music_player: AudioStreamPlayer = %MusicPlayer
@onready var menu_music_player: AudioStreamPlayer = %MenuMusicPlayer
@onready var secret_music_player: AudioStreamPlayer = %SecretMusicPlayer
@onready var secret_music_timer: Timer = $Audio/SecretMusicTimer


func _ready() -> void :
    print("Copyright Wilq1­©. Most rights reserved\n")
    menu_music_player.play()
    print("Now playing: The fire is gone - Heaven pierce her")
    leaderboard_check()
    
    
    update_leaderboard_label("user://leaderboard.nyb")
    game_over_label.hide()
    game_over_text_label.hide()
    score_label.hide()
    health_label.hide()
    welcome_label.show() 
    leader_label.hide()
    name_inputter.hide()
    blood_blur_1.hide()
    #print(str(load_from_file("user://leaderboard.nyb")))
    Engine.time_scale = 0.0
    
func _process(delta: float) -> void:
    
    if listening_for_input == true and Input.is_action_just_pressed("ui_text_submit") and name_inputted == true:
        get_tree().reload_current_scene.call_deferred()

func increase_score():
    playerScore += 1
    if not tempScore >= 15:
        tempScore += 1
    else:
        tempScore = 0
        if player_health < 5:
            heal_player(1)
    score_label.text = (    str(playerScore))
    
    if tempScore == 10:
        make_game_harder.emit()
    
    if playerScore == myTopScore+1:
        music_player.stream_paused = true
        secret_music_player.play()
        secret_music_timer.start()

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
    player_fell.emit()



func _on_player_deal_damage_to_player(amount: Variant) -> void :
    player_health -= amount
    #print("zadano")
    blood_blur_1.show()
    blood_timer.start()
    health_label.text = str(player_health)
    if player_health <= 0:
        player_died.emit()


func _on_player_died() -> void :
    music_player.stop()
    menu_music_player.stream_paused = false
    game_over_label.show()
    game_over_text_label.show()
    score_label.hide()
    health_label.hide()
    heart_green.hide()
    name_inputter.show()
    name_inputter.grab_focus()
    labels_state = 2
    update_leaderboard_label("user://leaderboard.nyb")
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    game_over_text_label.text = "
    Oh no! The bats got you!\nYour Score: " + str(playerScore)
    leader_label.show()
    Engine.time_scale = 0.0
    listening_for_input = true
    
func _on_start_game() -> void:
    menu_music_player.stream_paused = true
    var music = snapped(randf_range(0, 7), 1)
    var musicStream
    print(music)
    game_started = true
    game_over_label.hide()
    game_over_text_label.hide()
    score_label.show()
    health_label.show()
    welcome_label.hide()
    if music == 1:
        musicStream = preload("uid://cwudeva1iqfrx")
        print("Now playing: Ustopable force - Heaven pierce her")
    elif music == 2:
        musicStream = preload("uid://c3p5xe3rpmcl7")
        print("Now playing: Wednesday morning Bonk it's 9am - MIGUELANGELL960")
    elif music == 3:
        musicStream = preload("uid://34g3232cwcch")
        print("Now playing: The Only Thing They Fear Is You - Mick Gordon")
    elif music == 4:
        musicStream = preload("uid://d3ltf3bkrtm3g")
        print("Now playing: Versus - Heaven pierce her")
    elif music == 5:
        musicStream = preload("uid://bl01et1delrp3")
        print("Now playing: Castle Vein - Heaven pierce her")
    elif music == 6:
        musicStream = preload("uid://bt2wtl24so2fs")
        print("Now playing: Rip & Tear - Mick Gordon")   
    elif music == 7:
        musicStream = preload("uid://cv08so6fdk34j")
        print("Now playing: BFG Division - Mick Gordon")   
    else:
        musicStream = preload("uid://b33t1h14smnrv")
        print("Now playing: Spring - Concerned Ape")
    music_player.stream = musicStream
    music_player.play()
    
func _unhandled_input(event: InputEvent) -> void:
        if Input.is_action_just_pressed("shoot") and game_started == false:
            start_game.emit()
        else:
            pass

func save_to_file(content, filePath):
    var file = FileAccess.open(filePath, FileAccess.WRITE)
    file.store_string(content)

func load_from_file(filePath):
    var file = FileAccess.open(filePath, FileAccess.READ)
    var content = file.get_as_text()
    return content

func load_leaderboard(path):
    var scores = []
    
    if not FileAccess.open(path, FileAccess.READ):
        return scores
        
    var file = FileAccess.open(path, FileAccess.READ)
    var text = file.get_as_text()
    file.close()
    
    var lines = text.split("\n")
    
    for line in lines:
        line = line.strip_edges()
        if line == "":
            continue
        
        var parts = line.split(":")
        
        scores.append({
            "name": parts[0].strip_edges(),
            "score": int(parts[1].strip_edges())
        })
    scores.sort_custom(func(a,b): return a["score"] > b["score"])    
    
    return scores

func save_leaderboard(path, scores):

    var file = FileAccess.open(path, FileAccess.WRITE)

    for s in scores:
        file.store_line(s["name"] + ":" + str(s["score"]))
    var file1 = FileAccess.open(path, FileAccess.READ)
    print(file1.get_as_text())
    file.close()

func add_score(path, name, score):

    var scores = load_leaderboard(path)
    var found := false
    
    for s in scores:
        if s["name"] == name:
            if score > s["score"]:
                s["score"] = score
            found = true
            break
            
    if not found:
        scores.append({
            "name": name,
            "score": score
        })
    print(scores)
    scores.sort_custom(func(a,b): return a["score"] > b["score"])

    if scores.size() > 10:
        scores = scores.slice(0, 10)

    save_leaderboard(path, scores)
      
func update_leaderboard_label(path):

    var scores = load_leaderboard(path)
    var text = ""

    for i in scores.size():
        text += str(i+1) + ". " + scores[i]["name"] + " - " + str(scores[i]["score"]) + "\n"

    leader_label.text = text

func _on_name_inputter_text_submitted(new_text: String) -> void:
    var path = "user://leaderboard.nyb"
    if playerScore <= 0 or new_text == "":
        pass
    else:
        add_score(path, new_text, playerScore)
        update_leaderboard_label(path)
    timer.start()
    name_inputter.clear()
    
func _on_timer_timeout() -> void:
    name_inputted = true
    name_inputter.placeholder_text = "Press ENTER to proceed"

func _on_player_paused() -> void:
    music_player.stream_paused = true
    menu_music_player.stream_paused = false
    leader_label.show()

func _on_player_unpaused() -> void:
    music_player.stream_paused = false
    menu_music_player.stream_paused = true
    leader_label.hide()
    
func leaderboard_check():
    
    var file_path = "user://leaderboard.nyb"
    if not FileAccess.file_exists(file_path):
        var file = FileAccess.open(file_path, FileAccess.ModeFlags.WRITE_READ)
        file.store_line("Wilq1:"+str(myTopScore))
        file.flush()
        file.close()

func heal_player(amount):
    player_health += amount
    health_label.text = str(player_health)
     
func _on_blood_timer_timeout() -> void:
    blood_blur_1.hide()


func _on_secret_music_timer_timeout() -> void:
    music_player.stream_paused = false
