extends Node3D

var movement : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector3( abs(scale.x)/2, abs(scale.y)/2, 0 )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not movement or not movement.is_running():
		var disp = $%Mode2DX.display_size
		var half = Vector2( abs(scale.x)/2, abs(scale.y)/2 )
		var pos_tl = Vector3( half.x, half.y, 0 )
		var pos_tr = Vector3( disp.x-half.x, half.y, 0 )
		var pos_br = Vector3( disp.x-half.x, disp.y-half.y, 0 )
		var pos_bl = Vector3( half.x, disp.y-half.y, 0 )
		movement = create_tween()
		movement.tween_property( self, "position", pos_tr, 1 )
		movement.tween_property( self, "position", pos_br, 1 )
		movement.tween_property( self, "position", pos_bl, 1 )
		movement.tween_property( self, "position", pos_tl, 1 )
