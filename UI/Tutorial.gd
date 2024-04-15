extends TextureRect

#func _ready():
#    if not Constants.TutorialShown: show()

func _resume():
    Constants.TutorialShown = true

    hide()

    if GridController.Paused:
        GridController.toggle_pause()