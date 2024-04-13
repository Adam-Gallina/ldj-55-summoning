extends Node

var _curr_score = 0

func start_new_game():
    _curr_score = 0

func add_point(amount=1):
    _curr_score += amount

func get_score(): return _curr_score