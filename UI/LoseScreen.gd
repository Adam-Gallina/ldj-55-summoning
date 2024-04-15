extends TextureRect

@export var MenuPath : String = "res://main.tscn"

@onready var _score_label = get_node('%Score')
@onready var _highscore_label = get_node('%Highscore')

func _ready():
	hide()


func display_loss(score : int):
	_score_label.text = 'You delivered %d summoned items!' % score
	
	var hs = Leaderboard.get_player_highscore()
	if hs < score:
		_highscore_label.text = 'High Score!'
		Leaderboard.set_player_highscore(score)
	else:
		_highscore_label.text = 'Best score: %d' % hs

	show()
	

func _press_restart():
	get_tree().reload_current_scene()

func _press_menu():
	get_tree().change_scene_to_file(MenuPath)