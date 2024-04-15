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



func _on_colorblind_toggled(toggled_on:bool):
    Constants.ColorBlindMode = toggled_on

func _on_music_toggled(toggled_on:bool):
    GridController.get_node('AudioStreamPlayer').stream_paused = toggled_on

func _on_collisions_toggled(toggled_on:bool):
    Constants.CollisionAudio = toggled_on
