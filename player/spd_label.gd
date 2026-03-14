extends Label


# Called when the node enters the scene tree for the first time.

@export var player := NodePath(^"..")
@onready var _player: CharacterBody3D = $"../.."


# then each frame update the text
func _process(_delta: float) -> void:
    var speed = snapped(_player.velocity.length(), 1)
    # gets the magnitude of the player velocity (total speed in all directions)
    # and sets that as the text
    # str(...) is used to convert it to text here
    text = "Speed: " + str(speed)
    
