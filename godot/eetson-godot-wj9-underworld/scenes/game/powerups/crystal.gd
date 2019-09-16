extends MeshInstance

export var speed = 0.5

func _process(delta):
	rotate(Vector3(0,1,0), PI * delta * speed)

func _on_Area_body_entered(body):
	if body.get_name() == "kinematic-player":
		globals.score += 1
		if globals.score >= globals.total:
			transitionMgr.transitionTo("res://scenes/splash/splash-win.tscn", 0.5, false)
		queue_free()