extends Node2D

@export var PlayScene : PackedScene
@export var ZenScene : PackedScene


func _on_play_pressed():
    get_tree().change_scene_to_packed(PlayScene)

func _on_zen_pressed():
    get_tree().change_scene_to_packed(ZenScene)
