#!/usr/local/bin/red
Red [
	Title:   "Red Computer Vision: Gabor Filter"
	Author:  "Francois Jouen"
	File: 	 %rcvGabor.red
	Tabs:	 4
	Rights:  "Copyright (C) 2022 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

{Sigma : σ Represents the standard deviation of the Gaussian function > 0.0
Theta: θ Express Gabor Tilt angle of kernel function image	
Lambda:λ Indicates the wavelength of the filter  > 0
Psi : ψ Phase offset , The value range is -180~180
Gamma: γ Represents the aspect ratio , Decide this Gabor Ellipticity of kernel function} 


GaborKernel: function [
	sigma 	[float!]
	theta 	[float!]
	lambda	[float!]
	psi		[float!]
	gamma	[float!]
	return: [block!]
][
	;--Creation of the kernel
	nstds: 3 ;-- number of Standard deviation
	sigma_x: sigma
	sigma_y: sigma / gamma
	
	;--Bounding boxes
	v1: abs (nstds * sigma_x * cos theta)
	v2: abs (nstds * sigma_y * sin theta)
	dXmax: max v1 v2
	v1: abs(nstds * sigma_x * sin theta)
	v2: abs(nstds * sigma_y * cos theta)
	dYmax: max v1 v2
	xMax: to-integer max 1 round/ceiling dXmax
	yMax: to-integer max 1 round/ceiling dYmax
	dx: 2 * Xmax + 1
	dy: 2 * Ymax + 1
	x_theta: make vector! compose [float! (dx * dy)]     
	y_theta: make vector! compose [float! (dx * dy)] 
	
	;--2D Rotation
	i: 0
	while [i < dx][
		j: 0
		while [j < dy][
			idx: i + (j * dx) + 1 ;+1 Red Rebol are not Zero-based
			x_theta/:idx: (i - dx / 2) * cos (theta) + (j - dy / 2) * sin(theta)
			y_theta/:idx: 0.0 - (i - dx / 2) * sin (theta) + (j - dy / 2) * cos(theta)
			j: j + 1
		]
		i: i + 1
	]
	
	;--gabor kernel
	gabor: make vector! compose [float! (dx * dy)]
	i: 0
	while [i < dx][
		j: 0
		while [j < dy][
			idx: i + (j * dx) + 1 ;--+1 Red Rebol are not Zero-based
			gabor/:idx: exp(-0.5 * ((x_theta/:idx * x_theta/:idx) / (sigma_x * sigma_x) 
			+ (y_theta/:idx * y_theta/:idx) / (sigma_y * sigma_y))) * cos(2.0 * pi 
			/ lambda * x_theta/:idx + psi)
			j: j + 1
		]
		i: i + 1
	]
	;--for ulterior convolution on image
	b: []
	append b reduce [dx]
	append b reduce [dy]
	append b reduce [gabor]
	b
]

knl: GaborKernel 1.0 0.15 16.0 0.0 0.5

foreach v knl/3 [print v]

