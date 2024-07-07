extends Node

signal score_posted(successful : bool)
signal leaderboard(successful : bool, leaderboard)

const ScoreEndpoint = 'https://tracker.gallinagames.com/leaderboard/%s/score'
const LeaderboardEndpoint = 'https://tracker.gallinagames.com/leaderboard/%s/top'

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

func _ready():
    $GetLeaderboard.request_completed.connect(_on_leaderboard_retrieved)
    $PostScore.request_completed.connect(_on_score_posted)

func start_new_game():
    _playing = true
    _curr_score = 0

func end_game():
    _playing = false

func add_point(amount=1):
    if _playing:
        _curr_score += amount


func submit_score(player_name, score):
    var json = JSON.stringify({ 'name': player_name, 'score':score, 'key':'adamisthebest' })
    var headers = ["Content-Type: application/json", "Access-Control-Allow-Origin: *"]
    $PostScore.request(ScoreEndpoint % _curr_gamemode, headers, HTTPClient.METHOD_POST, json)

func get_leaderboard(count):
    var json = JSON.stringify({ 'count': count })
    var headers = ["Content-Type: application/json", "Access-Control-Allow-Origin: *"]
    $GetLeaderboard.request(LeaderboardEndpoint % _curr_gamemode, headers, HTTPClient.METHOD_GET, json)


func _on_leaderboard_retrieved(_result, response_code, _headers, body):
    if response_code != 200:
        leaderboard.emit(false, [])
    else:
        var lb = JSON.parse_string(body.get_string_from_utf8())
        leaderboard.emit(true, lb)

func _on_score_posted(_result, response_code, _headers, _body):
    score_posted.emit(response_code == 200)