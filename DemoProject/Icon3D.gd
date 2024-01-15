@tool
class_name Icon3D extends Node3D

var model

func _init( icon_name:String ):
	model = load( "res://Assets/kenny_food-kit/%s.glb" % [icon_name] ).instantiate()
	add_child( model )
	model.scale = Vector3( 100, 100, 100 )

func _process( dt ):
	model.rotation += Vector3( 0, dt, 0 )

