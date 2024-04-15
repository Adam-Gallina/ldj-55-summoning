extends TextureRect

@export var MenuPath : String = "res://main.tscn"


func _ready():
    hide()

func _toggle_menu():
    visible = not visible

    if visible != GridController.Paused:
        GridController.toggle_pause()

func _press_restart():
    get_tree().reload_current_scene()

func _press_menu():
    get_tree().change_scene_to_file(MenuPath)

func _press_tutorial():
    get_parent().get_node('Tutorial').show()
    hide()