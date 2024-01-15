@tool
extends Node3D

@onready var mode_2dx = $%Mode2DX

func add_icon( icon_name:String, pos:Vector2 ):
	var icon = Icon3D.new( icon_name )
	add_child( icon )
	var m2dx = $%Mode2DX  # @onready maybe hasn't happened yet
	m2dx.place( icon, pos )

func _process( _dt ):
	var list = get_tree().get_root().get_node("InventoryUI/Inventory")
	if list.item_count:
		position = Vector3( 0, list.get_v_scroll_bar().value, 0 )
