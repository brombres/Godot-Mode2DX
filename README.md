# Mode2DX
A Godot node that allows a 3D scene to use a standard 2D coordinate system.

About     | Current Release
----------|-----------------------
Version   | 1.0
Date      | July 5, 2023
Platform  | Godot 4
License   | [MIT License](LICENSE)
Author    | Brom Bresenham

# Usage

- Create a 3D scene.
- Add a Camera3D (default configuration is fine).
- Add [Mode2DX.gd](Mode2DX.gd) as a scene node.
- Drag the camera into the `camera` property of the `Mode2DX` node.
- All children and subtrees of `Mode2DX` will use 2D coordinates.
- (0,0) is top-left of the display.
- `$%Mode2DX.display_size` contains the current window size in pixels.
- `Mode2DX` will automatically update its configuration if the screen size changes.
- The scale * mesh size of each descendent node will be the pixel size it is drawn at.
    - For example, a `MeshInstance3D` quad scaled to 100x50x1 will be 100x50 pixels onscreen (if positioned at `z=0` as a child of `Mode2DX`).
- Because `Mode2DX` inverts the Y axis relative to standard 3D scenes, caveats apply:
    - The `scale.y` property of each child node or subtree root must be negatated. For example, to have a quad be drawn at 100x50 pixels you would set its `scale` to `(100,-50,1)`.
    - You should always take the `abs()` of a `Mode2DX` child node's `scale` before using it in computation. Because of the way that Godot stores 3D angles and scale in a combined "basis" form, you might set `rotation=(0,0,0), scale=(1,-1,1)` in the editor but when the game runs the properties would be `rotation:(0,180,0), scale:(-1,-1,-1)`.
- Mode2DX pairs well with the [3D Drawing Order Godot Engine modification](https://github.com/brombres/Godot-3D-Drawing-Order).

# Sample Project
This repo contains a sample project made in Godot 4.1-RC1. The only necessary file for your own projects is [Mode2DX.gd](Mode2DX.gd), which you can copy out separately.
