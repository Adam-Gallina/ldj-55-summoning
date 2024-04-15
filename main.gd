extends Node2D

@export var PlayScene : PackedScene
@export var ZenScene : PackedScene


func _on_play_pressed():
    Leaderboard.set_gamemode("normal")
    get_tree().change_scene_to_packed(PlayScene)

func _on_zen_pressed():
    Leaderboard.set_gamemode("zen")
    get_tree().change_scene_to_packed(ZenScene)
