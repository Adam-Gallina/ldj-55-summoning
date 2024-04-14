extends TextureRect

@export var MenuScene : PackedScene


func _ready():
    hide()

func _toggle_menu():
    visible = not visible

    if visible != GridController.Paused:
        GridController.toggle_pause()

func _press_restart():
    get_tree().reload_current_scene()

func _press_menu():
    get_tree().change_scene_to_packed(MenuScene)