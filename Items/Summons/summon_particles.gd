extends CPUParticles2D

func _ready():
    start_particles.call_deferred()

func start_particles():
    emitting = false
    await get_tree().create_timer(randf() * lifetime / amount).timeout
    emitting = true

func _process(_delta):
    if GridController.Paused:
        speed_scale = 0.
    elif GridController.FastForward:
        speed_scale = GridController.FastForwardSpeed
    else:
        speed_scale = 1.

func disconnect_particles(new_parent : Node):
    get_parent().remove_child(self)
    new_parent.add_child(self)
    
    # Make sure any additional particle spawns happen off screen
    position = GridController.to_world_pos(GridController.MinGrid * 2)

    one_shot = true
    await finished
    queue_free()