extends Node2D

@export var ChallengeScene : PackedScene
@export var InfiniteScene : PackedScene
@export var ZenScene : PackedScene

func _ready():
    if GridController.Paused: GridController.toggle_pause()


func _on_challenge_pressed():
    Leaderboard.set_gamemode("challenge")
    get_tree().change_scene_to_packed(ChallengeScene)

func _on_infinite_pressed():
    Leaderboard.set_gamemode("infinite")
    get_tree().change_scene_to_packed(InfiniteScene)

func _on_zen_pressed():
    Leaderboard.set_gamemode("zen")
    get_tree().change_scene_to_packed(ZenScene)

func _on_quit_pressed():
    get_tree().quit()
