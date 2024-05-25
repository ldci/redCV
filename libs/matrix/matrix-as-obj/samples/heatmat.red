#!/usr/local/bin/red
Red [
]

#include %../matrix-obj.red

w: h: 10.0	;--object size in mm
dx: dy: 0.1	;--intervals in x-, y- directions in mm
D: 4.0		;--Thermal diffusivity of object in mm2.s-1
tCold: 25.0	;--minimal temperature in degree	
tHot:  41.0	;--maximal temperature in degrees
nx: to-integer (w / dx)
ny:	to-integer (h / dy) 
dx2: dx * dx
dy2: dy * dy
dt: (dx2 * dy2) / (2.0 * D * (dx2 + dy2))

u0: matrix/init/value 3 64 as-pair nx ny tcold
u: matrix/_copy u0

;--Initial conditions - circle of radius r centred at (cx,cy) (mm)

r: 2
cx: cy: 5.0
r2: r ** 2.0
n: length? u0/data

repeat i nx [
	repeat j ny  [
		p2: ((i * dx - cx) ** 2.0) + ((j * dy - cy) ** 2.0)
		if p2 < r2 [matrix/_setAt u0 j i tHot]
	]
]

timeStep: does[
	l1: copy/part matrix/getRow u 1 nx - 2
	ln: copy/part matrix/getRow u ny nx - 2
	c1: copy/part matrix/getCol u 1 ny 
	cn: copy/part matrix/getCol u nx ny
	m0: matrix/slice u 2 ny - 1  2 nx - 1
	m1: matrix/slice u 2 ny - 1  2 nx - 1
	m12: matrix/scalarProduct m1 2.0
	m2: matrix/slice u 3 ny 2 nx - 1
	m3: matrix/slice u 1 ny - 2  2 nx - 1
	m4: matrix/slice u 2 ny - 1  3 nx
	m5: matrix/slice u 2 ny - 1  1 nx - 2
	mx0: matrix/scalarAddition  m1 (d * dt)
	mx1: matrix/subtraction m2 m12
	mx2: matrix/addition mx1 m3
	mx3: matrix/scalarDivision mx2 dx2
	mx4: matrix/subtraction m4 m12
	mx5: matrix/addition mx4 m5
	mx6: matrix/scalarDivision mx5 dy2
	mx7: matrix/addition mx3 mx6
	mx8: matrix/standardProduct mx0 mx7
	matrix/insertRow mx8 to-block l1
	matrix/AppendRow mx8 to-block ln
	matrix/insertCol mx8 to-block c1
	matrix/AppendCol mx8 to-block cn
	print ["Mat Order :" matrix/order mx8]
	print ["Mat Order :" matrix/order u]
	u: mx8
	u0: copy u
]
repeat i 10 [
	print i 
	timeStep
	matrix/show u0
]


