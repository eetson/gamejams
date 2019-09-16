extends KinematicBody

var target #Variable for current object Transform
var gravityCentre #Variable for gravity centre
var xVelocity = 0
var yVelocity = 0
var zVelocity = 0
var moveSpeed = 10
var rotation_helper
var camera
var grounded = false
var jumping = false
var doublejump = 0
var score = 0
var collisionInfo
export var gravity = 0.981
export var jumpStrength = 0.5

func _ready():
	rotation_helper = $RotationHelper
	camera = $RotationHelper/FPSCamera
	gravityCentre = get_parent_spatial().get_transform()
	zVelocity = 0
	xVelocity = 0

func _physics_process(delta):
	if (get_slide_count() > 0):
		grounded = true
	else:
		grounded = false
	#collisionInfo = get_slide_collision(0)
	#if (collisionInfo.collider_metadata

func _gui_input():
	pass

func _process(delta):
	# the idle boolean lets us root the character in place
	# whenever they aren't moving and are grounded
	var idle = true
	
	target = transform
	transform = orthonormalizePlanetary(target,gravityCentre)
	
	if (Input.is_action_pressed("ui_up")):
		zVelocity -= 0.1
		idle = false
	elif (Input.is_action_just_released("ui_up") && grounded):
		zVelocity = 0
		idle = false
	if (Input.is_action_pressed("ui_down")):
		zVelocity += 0.1
		idle = false
	elif (Input.is_action_just_released("ui_down") && grounded):
		zVelocity = 0
		idle = false
	if (zVelocity > 1):
			zVelocity = 1
	elif (zVelocity < -1):
			zVelocity = -1
	if (Input.is_action_pressed("ui_left")):
		xVelocity += 0.1
	elif (Input.is_action_just_released("ui_left")):
		xVelocity = 0
	if (Input.is_action_pressed("ui_right")):
		xVelocity -= 0.1
	elif (Input.is_action_just_released("ui_right")):
		xVelocity = 0
	if (xVelocity > 1):
			xVelocity = 1
	elif (xVelocity < -1):
			xVelocity = -1
			
	# Gravity and jumping
	if (grounded): 
		doublejump = 0
		
	if ((grounded || doublejump < 2) && Input.is_action_just_pressed("ui_select") && !jumping):
		jumping = true
		yVelocity = -jumpStrength
		idle = false
	else: 
		yVelocity += gravity * delta
	if (Input.is_action_just_released("ui_select")):
		jumping = false
		doublejump += 1
	
	if ((yVelocity != 0 && !idle) || !grounded):
		move_and_slide((target.basis.x*0 + target.basis.y*yVelocity + target.basis.z*zVelocity).normalized() * moveSpeed, Vector3.UP)
	else:
		zVelocity = 0
	#handle camera rotation here
	if (xVelocity != 0):
		rotate_object_local(Vector3.DOWN, xVelocity * PI * delta)
	#move_and_slide((target.basis.x*xVelocity + target.basis.y*yVelocity + target.basis.z*zVelocity).normalized() * speed)
	
	#die if we fall in lava
	var distance = transform.origin.distance_to(Vector3(0,0,0))
	if (distance > 37):
		game_over()

func orthonormalizePlanetary(t,p):
	var g #g is a gravity vector from current body to gravity centre
	var z #Z is forward direction as used at Unity3D
	var crossGZ #crossed and normalized product from g and z acts like new X-axis
	var newZ #crossed and normalized product from new X-axis and gravity vector
	g = (t.origin - p.origin).normalized()
	z = (t.origin + t.basis.z).normalized()
	crossGZ = g.cross(z).normalized()
	newZ = crossGZ.cross(g).normalized()
	return Transform(crossGZ,g,newZ,t.origin)
	
func game_over():
	transitionMgr.transitionTo("res://scenes/splash/splash-lose.tscn", 0.5, false)
	# YOU DIED
	queue_free()

func _on_feet_body_entered(body):
	if body.get_name() == "hollow-world":
		pass

func _on_feet_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.get_name() == "hollow-world":
		pass
