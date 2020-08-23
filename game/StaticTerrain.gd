tool
extends StaticBody2D

func _ready():
	$CollisionPolygon2D.polygon = $Polygon2D.polygon
	
	var size = $Polygon2D.polygon.size()
	var path = PoolVector2Array()
	path.resize(size + 1)
	for i in range(size):
		path[i] = $Polygon2D.polygon[i]
	path[size] = $Polygon2D.polygon[0]
		
	$Line2D.points = path
