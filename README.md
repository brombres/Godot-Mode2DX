# Mode2DX
A Godot node that allows a 3D scene to use a standard 2D coordinate system.

About     | Current Release
----------|-----------------------
Version   | 2.0
Date      | January 14, 2024
Platform  | Godot 4.x
License   | [MIT License](LICENSE)
Author    | Brom Bresenham

# Usage

- Create a 3D scene.
- Add a `Camera3D` (default configuration is fine).
- Add a `Mode2DX` node to the scene.
- Drag the camera into the `camera` property of the `Mode2DX` node.
- Add `Sprite3D` and other visual 3D nodes as children or descendants of the `Mode2DX` node.
- `(0,0)` is at the bottom-left of the viewport by default, with positive Y oriented up.
- Enabling the `top_left_origin` property will place `(0,0)` at the top-left with positive Y oriented down. The caveat is that children of `Mode2DX` will appear inverted, so they must be flipped or rotated 180º on the Y axis.
- `$%Mode2DX.display_size` contains the current viewport size in pixels.
- Method `place(node:Node3D,position:Vector2,[container_size:Vector2])` is a utility method that places a `Node3D` at the specified pixel position using a top-left-origin coordinate system regardless of whether `top_left_origin` is enabled or not. The `display_size`
- `Mode2DX` will automatically update its configuration if the screen size changes.
- The scale * mesh size of each descendent node will be the pixel size it is drawn at.
    - For example, a `MeshInstance3D` quad scaled to 100x50x1 will be 100x50 pixels onscreen (if positioned at `z=0` as a child of `Mode2DX`).
- Because `Mode2DX` inverts the Y axis relative to standard 3D scenes, caveats apply:
    - The `scale.y` property of each child node or subtree root must be negatated. For example, to have a quad be drawn at 100x50 pixels you would set its `scale` to `(100,-50,1)`.
    - You should always take the `abs()` of a `Mode2DX` child node's `scale` before using it in computation. Because of the way that Godot stores 3D angles and scale in a combined "basis" form, you might set `rotation=(0,0,0), scale=(1,-1,1)` in the editor but when the game runs the properties would be `rotation:(0,180,0), scale:(-1,-1,-1)`.
- Mode2DX pairs well with the [3D Drawing Order Godot Engine modification](https://github.com/brombres/Godot-3D-Drawing-Order).

# API

## Properties

Name              | Type       | Default | Description
------------------|------------|---------|-----------------------------
`camera`          | `Camera3D` |         | The `Camera3D` that will be automatically adjusted to use pixel coordinates.
`display_size`    | `Vector2`  |         | The current size of the viewport, in pixels. `(0,0)` is the top-left corner and positive Y is down if `top_left_origin` is `true`, otherwise `(0,0)` is the bottom-left corner and positive Y is up.
`nominal_z`       | `float`    | `2000`  | The depth at which 3D model size matches pixel size 1:1. The Mode2DX node is positioned at this depth, so a child node with z=0 will have a 1:1 pixel size, a node with a positive `z` will be closer to the camera, and a node with negative `z` will be farther from the camera.<br><br>Smaller `nominal_z` values exaggerate the effects of rotating into or moving along the Z axis, while larger `nominal_z` values reduce the depth of the 3D effect.
`top_left_origin` | `bool`     | `false` | Enabling this setting will put the `(0,0)` origin in the top-left corner instead of the bottom-left corner for child nodes of this `Mode2DX` node, and down will now be y-positive instead of y-negative. This matches the orientation conventional 2D coordinate systems. However, child nodes will appear inverted by default, so they must be flipped or rotated 180º on the Y axis.  It may be easier to leave `top_left_origin` off and utlize `place()` and `get_placement()` to set and get node positions using top-left-relative coordinates.
`z_far`           | `float`    | `4000`  | The far clipping plane. Note that the near clipping plane is fixed at `1`.

## Methods

Signature         | Description
------------------|-------------
`get_placement(node:Node3D,[container_size:Vector2])->Vector2` | Returns the specified node's position as [Vector2] relative to a top-left origin of `(0,0)`, regardless of whether `top_left_origin` is set or not. `container_size` is optional and may be used to specify the width and height of the local coordinate system; `display_size` is used if `container_size` is unspecified.
`invert_y(pos:Variant,[container_size:Vector2])->Variant` | Inverts the Y coordinate of a vector, `Rect2`, or `AABB`, relative to the viewport display size or the specified `container_size`. `get_placement()` and `place()` utilize this method. Call it directly invert a `Rect2` or `AABB`.
`place(node:Node3D,position:Variant,[container_size:Vector2])` | Places `node` at the specified position. `pos` is a `Vector2` or `Vector3` that is relative to a top-left `code`(0,0)`/code` origin, regardless of whether `top_left_origin` is set or not. `container_size` is optional and may be used to specify the width and height of the local coordinate system; `display_size` is used if `container_size` is unspecified.
`update_display_settings([force_update:bool])` | Called automatically on `_ready()` and when the viewport size changes. Can be called manually e.g. to update `display_size` immediately after the current camera is changed.  Pass `true` to force an update even if the viewport size hasn't changed.
