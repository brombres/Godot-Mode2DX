@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type( "Mode2DX", "Node3D", preload("Mode2DX.gd"), preload("Mode2DX.png") )

func _exit_tree():
	remove_custom_type( "Mode2DX" )
