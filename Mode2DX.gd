@tool

## Mode2DX allows standard pixel coordinates to be used in a 3D scene. Child nodes of a
## Mode2DX node will use coordinates that match viewport pixel coordinates 1:1.
class_name Mode2DX extends Node3D

## Mode2DX receives the viewport's 'size_changed' signal and then updates the 2DX display settings
## before emitting the 'display_size_changed' signal. Connecting to this signal ensures that
## Mode2DX.display_size is up to date before the receiver performs any layout adjustments.
signal display_size_changed(Vector2)

## The Camera3D that will be automatically adjusted to use pixel coordinates.
@export var camera : Camera3D :
	set(value):
		if camera != value:
			camera = value
			if Engine.is_editor_hint() and camera and _is_ready:
				print( "[Mode2DX] Camera connected. Reselect the camera and add a checkmark to the 'Preview' box in the Editor viewport to see the scene in 2DX." )

## The current size of the viewport, in pixels. (0,0) is the top-left corner.
var display_size : Vector2

var _is_ready := false

## The depth at which 3D model size matches pixel size 1:1. The Mode2DX node is positioned at this
## depth, so a child node with z=0 will have a 1:1 pixel size, a node with a positive [code]z[/code] will be
## closer to the camera, and a node with negative [code]z[/code] will be farther from the camera.
##
## Smaller [member nominal_z] values exaggerate the effects of rotating into or moving along the Z axis,
## while larger [member nominal_z] values reduce the depth of the 3D effect.
@export var nominal_z = 2000:
	set(value):
		if nominal_z != value:
			nominal_z = value
			if _is_ready: update_display_settings( true )

## The far clipping plane. Note that the near clipping plane is fixed at 1.
@export var z_far = 4000:
	set(value):
		if z_far != value:
			z_far = value
			if _is_ready: update_display_settings( true )

## Enabling this setting will put the (0,0) origin in the top-left corner instead of the bottom-left
## corner for child nodes of this Mode2DX node, and down will now be y-positive instead of y-negative.
## This matches the orientation conventional 2D coordinate systems. However, child nodes will appear
## inverted by default, so they must be flipped or rotated 180 degrees on the Y axis. It may be
## easier to leave [member top_left_origin] off and utlize [method place] and [method get_placement]
## to set and get node positions in top-left-relative coordinates.
@export var top_left_origin := false :
	set(value):
		if top_left_origin != value:
			top_left_origin = value
			if _is_ready: update_display_settings( true )

## Returns the specified node's position as [Vector2] relative to a top-left origin of [code](0,0)[/code],
## regardless of whether [member top_left_origin] is set or not. [param container_size] is optional and may be
## used to specify the width and height of the local coordinate system; [member display_size] is used if
## [param container_size] is unspecified.
func get_placement( node:Node3D, container_size:Variant=null )->Vector2:
	var result = Vector2( node.position.x, node.position.y )
	if top_left_origin: return result
	else :              return invert_y( result, container_size )

## Inverts the Y coordinate of a vector, [Rect2], or [AABB], relative to the viewport display size
## or the specified [param container_size]. [method get_placement] and [method place] utilize this method.
## Call it directly to invert a [Rect2] or [AABB].
func invert_y( pos:Variant, container_size:Variant=null )->Variant:
	if not container_size: container_size = display_size
	match typeof(pos):
		TYPE_VECTOR2:   pos.y = container_size.y - pos.y
		TYPE_VECTOR2I:  pos.y = container_size.y - pos.y
		TYPE_RECT2:     pos.position.y = container_size.y - pos.end.y
		TYPE_RECT2I:    pos.position.y = container_size.y - pos.end.y
		TYPE_VECTOR3:   pos.y = container_size.y - pos.y
		TYPE_VECTOR3I:  pos.y = container_size.y - pos.y
		TYPE_VECTOR4:   pos.y = container_size.y - pos.y
		TYPE_VECTOR4I:  pos.y = container_size.y - pos.y
		TYPE_AABB:      pos.position.y = container_size.y - pos.end.y
	return pos

## Places [param node] at the specified position. [param pos] is a [Vector2] or [Vector3] that
## is relative to a top-left [code](0,0)[/code] origin, regardless of whether [member top_left_origin]
## is set or not. [param container_size] is optional and may be used to specify the width and height
## of the local coordinate system; [member display_size] is used if [param container_size] is unspecified.
func place( node:Node3D, pos:Variant, container_size:Variant=null ):
	pos = Vector3( pos.x, pos.y, node.position.z )
	if top_left_origin: node.position = pos
	else:               node.position = invert_y( pos, container_size )

## Called automatically on [method _ready] and when the viewport size changes. Can be
## called manually e.g. to update [member display_size] immediately after the current camera is changed.
## Pass [code]true[/code] to force an update even if the viewport size hasn't changed.
func update_display_settings( force_update:bool=false ):
	if not camera:
		if not Engine.is_editor_hint(): printerr( "[Mode2DX] No camera assigned." )
		return

	var viewport = EditorInterface.get_editor_viewport_3d(0) if Engine.is_editor_hint() else get_viewport()
	if not viewport: return

	var new_display_size = viewport.get_visible_rect().size
	if display_size == new_display_size and not force_update: return
	display_size = new_display_size

	var k = (nominal_z + 1)
	var size = display_size.y / k
	camera.set_frustum( size, Vector2(), 1, z_far )

	var offset = display_size/2
	if top_left_origin: offset.y = -offset.y
	position = Vector3( -offset.x, -offset.y, -nominal_z )
	rotation = Vector3()
	scale = Vector3( 1, (-1 if top_left_origin else 1), 1 )

	print( str("[Mode2DX] ", camera.name, ".set_frustum(",size,",Vector2(0,0),1,",z_far,")") )
	print( str("[Mode2DX] ", name, ".position = ",position) )
	print( str("[Mode2DX] ", name, ".scale = ",scale) )

	if Engine.is_editor_hint():
		for connection in display_size_changed.get_connections():
			if connection.callable.get_object().get_script().is_tool():
				connection.callable.call( display_size )
	else:
		display_size_changed.emit( display_size )

func _process( _dt ):
	if Engine.is_editor_hint(): update_display_settings()

func _ready():
	_is_ready = true
	unique_name_in_owner = true  # enable access using $%Mode2DX and get_node("%Mode2DX")
	get_viewport().connect( "size_changed", _on_viewport_size_changed )
	update_display_settings()

func _on_viewport_size_changed():
	update_display_settings()
