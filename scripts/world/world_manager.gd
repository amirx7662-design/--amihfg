extends Node3D

# ⚙️ إعدادات العالم
var chunk_size = 16
var render_distance = 8
var chunks = {}

# Noise للتوليد العشوائي
var noise: FastNoiseLite

func _ready():
	print("🌍 تم تحميل مدير العالم")
	
	# إعداد الـ Noise
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.05
	
	generate_initial_world()

func generate_initial_world():
	"""توليد العالم الأولي حول اللاعب"""
	var player_pos = get_tree().get_first_node_in_group("player").global_position
	var player_chunk = get_chunk_coords(player_pos)
	
	# توليد الأشنكات حول اللاعب
	for x in range(player_chunk.x - render_distance, player_chunk.x + render_distance):
		for z in range(player_chunk.z - render_distance, player_chunk.z + render_distance):
			generate_chunk(Vector2i(x, z))

func get_chunk_coords(position: Vector3) -> Vector2i:
	"""الحصول على إحداثيات الشنك من الموضع"""
	return Vector2i(int(position.x / chunk_size), int(position.z / chunk_size))

func generate_chunk(chunk_coords: Vector2i):
	"""توليد شنك جديد"""
	if chunk_coords in chunks:
		return
	
	var chunk = Node3D.new()
	chunk.name = "Chunk_%d_%d" % [chunk_coords.x, chunk_coords.z]
	chunk.position = Vector3(chunk_coords.x * chunk_size, 0, chunk_coords.y * chunk_size)
	
	add_child(chunk)
	chunks[chunk_coords] = chunk
	
	# إضافة الأرض والعناصر
	add_ground_to_chunk(chunk, chunk_coords)
	add_trees_to_chunk(chunk, chunk_coords)

func add_ground_to_chunk(chunk: Node3D, chunk_coords: Vector2i):
	"""إضافة أرضية للشنك"""
	var ground = CSGBox3D.new()
	ground.size = Vector3(chunk_size, 1, chunk_size)
	ground.position = Vector3(chunk_size / 2.0, -0.5, chunk_size / 2.0)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.GREEN
	ground.set_material(material)
	
	chunk.add_child(ground)
	
	# إضافة تصادم
	var collision = CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	collision.shape.size = Vector3(chunk_size, 1, chunk_size)
	collision.position = Vector3(chunk_size / 2.0, -0.5, chunk_size / 2.0)
	chunk.add_child(collision)

func add_trees_to_chunk(chunk: Node3D, chunk_coords: Vector2i):
	"""إضافة أشجار للشنك"""
	var tree_count = 3
	for i in range(tree_count):
		var random_seed = (chunk_coords.x + i) * 73856093 ^ (chunk_coords.y + i) * 19349663
		randomize()
		
		var x = randf() * chunk_size
		var z = randf() * chunk_size
		
		# الجذع
		var trunk = CSGBox3D.new()
		trunk.size = Vector3(1, 4, 1)
		trunk.position = Vector3(x, 2, z)
		
		var trunk_material = StandardMaterial3D.new()
		trunk_material.albedo_color = Color.BROWN
		trunk.set_material(trunk_material)
		
		chunk.add_child(trunk)
		
		# أوراق الشجرة
		var leaves = CSGSphere3D.new()
		leaves.radius = 2
		leaves.position = Vector3(x, 5, z)
		
		var leaves_material = StandardMaterial3D.new()
		leaves_material.albedo_color = Color.GREEN
		leaves.set_material(leaves_material)
		
		chunk.add_child(leaves)

func _process(_delta):
	"""تحديث الأشنكات بناءً على موقع اللاعب"""
	update_chunks()

func update_chunks():
	"""تحديث الأشنكات المرئية"""
	var player_pos = get_tree().get_first_node_in_group("player").global_position
	var player_chunk = get_chunk_coords(player_pos)
	
	# توليد أشنكات جديدة إذا لزم الأمر
	for x in range(player_chunk.x - render_distance, player_chunk.x + render_distance):
		for z in range(player_chunk.z - render_distance, player_chunk.z + render_distance):
			generate_chunk(Vector2i(x, z))
