extends KinematicBody
var target #Variable for current object Transform
var gravityCentre #Variable for gravity centre
var xVelocity
var zVelocity
var speed = 0.5
var rotation_helper
var camera

func _ready():
	rotation_helper = $RotationHelper
	camera = $RotationHelper/FPSCamera
	gravityCentre = get_parent_spatial().get_transform()
	zVelocity = 0
	xVelocity = 0

func _process(delta):
	target = transform
	#print(state.get_total_gravity()) #Information for testing
	transform = orthonormalizePlanetary(target,gravityCentre)
	zVelocity -= 0.1
	if (zVelocity > 1):
			zVelocity = 1
	elif (zVelocity < -1):
			zVelocity = -1
	xVelocity -= 0.1
	if (xVelocity > 1):
			xVelocity = 1
	elif (xVelocity < -1):
			xVelocity = -1
	move_and_slide((target.basis.x*xVelocity+target.basis.z*zVelocity).normalized() * speed)

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