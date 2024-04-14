extends GridObject

@export var FilteredObject : int

@export var EmptyRate = 8
@export var LoseAmount = 12
var _curr_amount = 0
@onready var _next_gain = EmptyRate

@onready var _amount_bar : TextureProgressBar = $TextureProgressBar

func _ready():
    GridController.tick.connect(_on_tick)

    _amount_bar.max_value = LoseAmount
    _amount_bar.value = LoseAmount

func set_empty_rate(rate : int):
    EmptyRate = rate
    _next_gain = min(_next_gain, EmptyRate)

func summon_interact(summon : SummonObject):
    if summon.ObjectNum == FilteredObject:
        summon.despawn()
        ScoreBoard.add_point()
        _curr_amount -= 1
        if _curr_amount < -1: _curr_amount = -1
        
        _amount_bar.value = LoseAmount - _curr_amount


func _on_tick():
    _next_gain -= 1

    if _next_gain <= 0:
        _curr_amount += 1
        _next_gain = EmptyRate

        _amount_bar.value = LoseAmount - _curr_amount

        if _curr_amount == LoseAmount:
            print("Womp Womp")