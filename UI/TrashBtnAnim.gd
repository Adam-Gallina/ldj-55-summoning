extends Button

@export var LidOpenDist = 200

var _hovering = false
var _lid = false

func play_trash():
    $AnimationPlayer.play("deposit")
    $AudioStreamPlayer.play()
    _hovering = false


func _process(_delta):
    if _hovering:
        if not _lid and position.distance_to(get_global_mouse_position()) <= LidOpenDist:
            $AnimationPlayer.play("lid_open")
            _lid = true
        elif _lid and position.distance_to(get_global_mouse_position()) > LidOpenDist:
            $AnimationPlayer.play("lid_close")
            _lid = false


func _on_object_selected(_obj):
    $AnimationPlayer.play("trash_visible")
    _hovering = true

func _on_object_placed(_obj):
    $AnimationPlayer.play("trash_hidden")
    _hovering = false