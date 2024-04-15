extends GridObject
class_name OutputPortal

signal portal_filled(portal)
signal portal_warning(portal)

@export var SkipAnim : bool = false

@export var FilteredObject : int

@export var EmptyRate = 8
@export var LoseAmount = 12
@export var WarningAmount = 8
@export var PanicAmount = 10
var _curr_amount = 0
@onready var _next_gain = EmptyRate

@onready var _amount_bar : TextureProgressBar = $TextureProgressBar

var _jiggled = false

@onready var _colorblind_img = $Sprite2D

func _ready():
	if not SkipAnim:
		$AnimationPlayer.play("spin")

	GridController.tick.connect(_on_tick)

	_amount_bar.max_value = LoseAmount
	_amount_bar.value = LoseAmount

	remove_child(_colorblind_img)
	get_parent().add_child.call_deferred(_colorblind_img)

func set_empty_rate(rate : int):
	EmptyRate = rate
	_next_gain = EmptyRate if _next_gain == null else min(_next_gain, EmptyRate)

	get_node('%EveryFour').visible = rate < 9
	get_node('%EveryTwo').visible = rate < 5
	get_node('%EveryOne').visible = rate == 2

func summon_interact(summon : SummonObject):
	if _curr_amount <= -1 and EmptyRate > 0: return

	if summon.ObjectNum == FilteredObject:
		summon.despawn()
		Leaderboard.add_point()
		_curr_amount -= 1
		if _curr_amount < -1: _curr_amount = -1
		
		_amount_bar.value = LoseAmount - _curr_amount

func set_summon_img(texture):
	_colorblind_img.texture = texture

func do_pulse():
	$AnimationPlayer.play("pulse")

func _process(_delta):
	_colorblind_img.position = position
	_colorblind_img.visible = Constants.ColorBlindMode

func _on_tick():
	_next_gain -= 1


	if _next_gain <= 0 and EmptyRate > 0:
		_curr_amount += 1
		_next_gain = EmptyRate

		_amount_bar.value = LoseAmount - _curr_amount

		if _curr_amount == LoseAmount:
			portal_filled.emit(self)
			$CPUParticles2D.emitting = true

	if _curr_amount >= PanicAmount:
		portal_warning.emit(self)
		$AudioStreamPlayer.play()
	elif _curr_amount >= WarningAmount:
		if _jiggled:
			_jiggled = false
		else:
			portal_warning.emit(self)
			$AudioStreamPlayer.play()
			_jiggled = true