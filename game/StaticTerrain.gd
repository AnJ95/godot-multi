tool
extends StaticBody2D

func _ready():
	
	for collision in get_children():
		var polygon = collision.get_node("Polygon2D")
		var line = collision.get_node("Line2D")
		
		polygon.polygon = collision.polygon
		
		var size = collision.polygon.size()
		var path = PoolVector2Array()
		path.resize(size + 1)
		for i in range(size):
			path[i] = collision.polygon[i]
		path[size] = collision.polygon[0]
		line.points = path
