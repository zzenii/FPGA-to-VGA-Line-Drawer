# FPGA-to-VGA-Line-Drawer

SystemVerilog implementation of the Bresenham line algorithm. The system can draw a line between any two points on a 640x480 VGA display.

The project was broken down into two steps. First, the pseudo-code of the Bresenham line algorithm found below was implemented as line_drawer.sv. It is this module that can implement the desired line-drawing functionality described above.

```
1 draw line(x0, x1, y0, y1)
2
3 boolean is_steep = abs(y1 − y0) > abs(x1 − x0)
4 if is_steep then
5 swap(x0, y0)
6 swap(x1, y1)
7 if x0 > x1 then
8 swap(x0, x1)
9 swap(y0, y1)
10
11 int delta_x = x1 − x0
12 int delta_y = abs(y1 − y0)
13 int error = −(delta_x / 2)
14 int y = y0
15 if y0 < y1 then y_step = 1 else y_step = − 1
16
17 for x from x0 to x1
18 if is_steep then
19 draw_pixel(y,x)
21 else
22 draw_pixel(x,y)
23 error = error + delta_y
24 if error ≥ 0 then
25 y = y + y_step
26 error = error − delta_x
```
The second step consisted of creating modules sim_calculator and clear_screen to produce a line-drawing animation and clear the VGA display, respectively.

Lines are 'drawn' on the VGA by writing a white pixel (RGB value = 24'hFFFFFF) to the VGA framebuffer, at the address specified by coordinates $x$ and $y$. 

This design can be tested using a physical DE1_SoC board (with VGA display) or through virtual engines such as LabsLand, with DE1_SoC.sv defined as the top-level module. To start the animation, press KEY0. To end it / clear the screen, press KEY3.
