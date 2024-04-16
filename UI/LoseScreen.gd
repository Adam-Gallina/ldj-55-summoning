extends TextureRect

@export var MenuPath : String = "res://main.tscn"

@onready var _score_label = get_node('%Score')
@onready var _highscore_label = get_node('%Highscore')

@export var MaxNameLength = 20
@onready var _name_input = $Background2/TextEdit
@onready var _leaderboard = $Background2/VBoxContainer
@onready var _leaderboard_error = $Background2/ErrorLabel

func _ready():
	hide()

	Leaderboard.score_posted.connect(_on_score_posted)
	Leaderboard.leaderboard.connect(_on_leaderboard_retrieved)

	_leaderboard_error.hide()


func display_loss(score : int):
	_score_label.text = 'You delivered %d summoned items!' % score
	
	var hs = Leaderboard.get_player_highscore()
	if hs < score:
		_highscore_label.text = 'High Score!'
		Leaderboard.set_player_highscore(score)
	else:
		_highscore_label.text = 'Best score: %d' % hs

	Leaderboard.get_leaderboard(5)

	show()
	

func _press_restart():
	get_tree().reload_current_scene()

func _press_menu():
	get_tree().change_scene_to_file(MenuPath)


func _on_name_text_changed():
	if _name_input.text.length() > MaxNameLength:
		_name_input.text = _name_input.text.substr(0, MaxNameLength)

func _press_submit():
	if _name_input.text.length() > 0:
		Leaderboard.submit_score(_name_input.text, Leaderboard.get_curr_score())
		$Background2/SubmitScore.disabled = true


func _on_score_posted(successful : bool):
	if successful:
		Leaderboard.get_leaderboard(5)
	else:
		_leaderboard_error.show()
		_leaderboard.hide()

func _on_leaderboard_retrieved(successful : bool, leaderboard):
	if successful:
		var i = 0
		for pos in leaderboard:
			_leaderboard.get_child(i).show()
			_leaderboard.get_child(i).text = '%d. %s: %d' % [i+1, pos.name, pos.score]
			i += 1
		for j in range(i, 5):
			_leaderboard.get_child(j).hide()
	else:
		_leaderboard_error.show()
		_leaderboard.hide()