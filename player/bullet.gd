extends Area3D


const SPEED = 70.0
const RANGE = 65.0

var travelledDistance = 0.0

func _ready() -> void:
    var parent = get_parent()
    #print(parent)
    global_rotation_degrees = parent.global_rotation_degrees


func _physics_process(delta: float) -> void :
    position += transform.basis.z * SPEED * delta
    travelledDistance += SPEED * delta
    if travelledDistance > RANGE:
        queue_free()


func _on_body_entered(body: Node3D) -> void :
    queue_free()
    if body.has_method("take_damage"):
        body.take_damage()
