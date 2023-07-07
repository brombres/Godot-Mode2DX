# Mode2DX.gd
# v1.1
# July 7, 2023 by Brom Bresenham

## Mode2DX allows standard pixel coordinates to be used in a 3D scene. Add a Mode2DX node to the
## scene and assign the scene's Camera3D to it. The positions of children you add to Mode2DX are
## treated as pixel coordinates, with (0,0) being the top-left of the display. Two caveats: 1) Each
## child node or subtree root must have a negative Y scale. 2) Always take the abs() of a child
## nodes's scale before using it in a computation (applies to X, Y, and Z scale components). Mode2DX
## makes itself a unique name so that other scripts can access it with '$%Mode2DX' AKA
## 'get_node("%Mode2DX")' (or whatever this node is renamed to).
class_name Mode2DX
extends Node3D

## Mode2DX receives the viewport's 'size_changed' signal and then updates the 2DX display settings
## before emitting the 'display_size_changed' signal. Connecting to this signal ensures that
## Mode2DX.display_size is up to date before the receiver performs any layout adjustments.
signal display_size_changed(Vector2)

## The Camera3D that will be automatically adjusted to use pixel coordinates.
@export var camera : Camera3D

## The current size of the viewport, in pixels. (0,0) is the top-left corner.
var display_size : Vector2

## The depth at which 3D model size matches pixel size 1:1. The Mode2DX node is positioned at this
## depth, so a child node with z=0 will have a 1:1 pixel size, a node with z=nominal_z*0.9 will be
## closer to the camera, and a node with z=nominal_z*1.1 will be farther from the camera.
##
## Smaller nominal_z values exaggerate the effects of rotating into or moving along the Z axis,
## while larger nominal_z values reduce the depth of the 3D effect.
@export var nominal_z = 2000:
	set(value):
		if value != nominal_z: nominal_z=value; update_display_settings()

## The far clipping plane. Note that the near clipping plane is fixed at 1.
@export var z_far = 4000:
	set(value):
		if value != z_far: z_far=value; update_display_settings()

func update_display_settings():
	# Called automatically on _ready(), when the viewport size changes, and from _process(). Can be
	# called manually e.g. to update 'display_size' immediately after the current camera is changed.
	if not camera:
		printerr( "[Mode2DX] No camera assigned." )
		return

	var viewport = get_viewport()
	if not viewport: return

	display_size = viewport.get_visible_rect().size

	var k = (nominal_z + 1)
	var size = display_size.y / k
	camera.set_frustum( size, Vector2(), 1, z_far )

	var offset = display_size/2
	position = Vector3( -offset.x, offset.y, -nominal_z )
	rotation = Vector3()
	scale = Vector3( 1, -1, 1 )

	print( str("[Mode2DX] ", camera.name, ".set_frustum(",size,",Vector2(),1,",z_far,")") )
	print( str("[Mode2DX] ", name, ".position = ",position) )
	print( str("[Mode2DX] ", name, ".scale = ",scale) )

	display_size_changed.emit( display_size )

func _ready():
	unique_name_in_owner = true  # enable access using $%Mode2DX and get_node("%Mode2DX")
	get_viewport().connect( "size_changed", _on_viewport_size_changed )
	update_display_settings()

func _on_viewport_size_changed():
	update_display_settings()
