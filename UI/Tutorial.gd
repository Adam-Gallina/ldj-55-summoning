extends TextureRect

@export var WelcomePanel : Control
@export var PortalPanel : Control
@export var ToolsPanel : Control
@export var TimeControlPanel : Control

func _ready():
    hide()
    return
    if not Constants.TutorialShown: 
        show()
        GridController.toggle_pause.call_deferred()
        $Panel/Resume.disabled = true

        WelcomePanel.show()
        PortalPanel.hide()
        ToolsPanel.hide()
        TimeControlPanel.hide()

func _resume():
    Constants.TutorialShown = true

    WelcomePanel.show()
    PortalPanel.hide()
    ToolsPanel.hide()
    TimeControlPanel.hide()
    hide()

    if GridController.Paused:
        GridController.toggle_pause()


func _welcome_next():
    WelcomePanel.hide()
    PortalPanel.show()

func _portal_next():
    PortalPanel.hide()
    ToolsPanel.show()

func tools_next():
    ToolsPanel.hide()
    TimeControlPanel.show()
    $Panel/Resume.disabled = false
