extends CSGMesh

onready var column1 = preload("res://scenes/game/column/column1.tscn")
onready var column2 = preload("res://scenes/game/column/column2.tscn")
onready var column3 = preload("res://scenes/game/column/column3.tscn")
onready var crystal = preload("res://scenes/game/powerups/score-crystal.tscn")
var player

# world is a building block of 1 unit, scaled 40x
# offset equals the intended 4x unit scale for 1 unit sized columns
var cScale = 0.1

func _ready():
	player = get_parent().get_node("kinematic-player")
	make_level()

# Populate lava faces with stone columns
func make_level():
	globals.score = 0
	globals.total = 0
	var surf = MeshDataTool.new()
	surf.create_from_surface(mesh, 0)
	var randomPlayerSpawn = randi() % surf.get_face_count()
	for i in range (surf.get_face_count()):
		# average vertex positions to get triangle center
		var tri1 = surf.get_vertex(surf.get_face_vertex(i, 0))
		var tri2 = surf.get_vertex(surf.get_face_vertex(i, 1))
		var tri3 = surf.get_vertex(surf.get_face_vertex(i, 2))
		var v = Vector3(tri1.x + tri2.x + tri3.x, tri1.y + tri2.y + tri3.y, tri1.z + tri2.z + tri3.z) / 3
		var normal = surf.get_face_normal(i)
		
		# orient and randomly rotate along the normal
		var y = normal
		var x = normal.cross(Vector3(0,1,0)).normalized() if normal != Vector3(0,1,0) else normal.cross(Vector3(0,1,0))
		var z = x.cross(y).normalized()
		var basis = Basis(x, y, z)
		
		basis = basis.scaled(Vector3(cScale * rand_range(0.9, 1.1), cScale  * rand_range(0.9, 1.1), cScale  * rand_range(0.9, 1.1)))
		basis = basis.rotated(y, rand_range(0, 2) * PI)
		
		# rotate 180° because we use inverted normals
		basis = basis.rotated(x, PI)
		
		# spawn the column as a child and apply transform
		var columnInstance
		
		# random columns, change values for different weighting
		var roll = rand_range(0,11)
		if (i == randomPlayerSpawn || roll <= 9):
			if roll < 4:
				columnInstance = column1.instance()
			elif roll < 8:
				columnInstance = column2.instance()
			else:
				columnInstance = column3.instance()
			
			# 50% chance to flip the column mesh for more variety
			if (rand_range(0,1) > 0.5):
				columnInstance.get_node("MeshInstance").transform.basis.rotated(x, PI)
		
			# Place column and slot its spawnpoint
			columnInstance.transform = Transform(basis, v)
			add_child(columnInstance)
			# add crystals and spawn a player
			roll = rand_range(0,1)
			var spawnPoint = columnInstance.get_node("spawnpoint")
			if (i == randomPlayerSpawn):
				player.transform = Transform(spawnPoint.transform.basis, spawnPoint.transform.origin) 
				player.orthonormalize()
			elif roll < 0.1:
				var crystalInstance = crystal.instance()
				spawnPoint.add_child(crystalInstance)
				crystalInstance.transform = Transform(spawnPoint.transform.basis, Vector3(0,0,0))
				crystalInstance.transform.basis = crystalInstance.transform.basis.scaled(Vector3(0.5, 0.5, 0.5))
				globals.total += 1