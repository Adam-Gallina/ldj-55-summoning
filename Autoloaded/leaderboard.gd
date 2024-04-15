extends Node

var _curr_gamemode : String = 'Unknown'
var _curr_score : int= 0
var _curr_highscores : Dictionary = {}
var _playing = false

func get_curr_score() -> int: return _curr_score

func get_player_highscore() -> int:
    return _curr_highscores.get(_curr_gamemode, 0)

func set_player_highscore(score : int):
    _curr_highscores[_curr_gamemode] = score

func set_gamemode(mode : String):
    _curr_gamemode = mode

func start_new_game():
    _playing = true
    _curr_score = 0

func end_game():
    _playing = false

func add_point(amount=1):
    if _playing:
        _curr_score += amount