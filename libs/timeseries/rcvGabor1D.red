Red[
	Title:   "Red Computer Vision: 1-D Gabor Filter"
	Author:  "Francois Jouen"
	File: 	 %rcvGabor1D.red
	Tabs:	 4
	Rights:  "Copyright (C) 2022 François Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;f_Gabor(x) = cos(frequency*x) * exp(-(x*x)/(sigma*sigma))

gabor1D: function [
	x		[float!];--signal value
	f		[float!];--frequency
	sigma	[float!];--variance
	return: [float!]
	
][
	cosPart: cos (f * x)
	gaussPart: exp (negate (x * x) / (sigma * sigma))
	cosPart * gaussPart
]

;--test 
blk: [-5.0 -4.0 -3.0 -2.0 -1.0 0.0 1.0 2.0 3.0 4.0 5.0]
foreach v blk [print [v gabor1D v 4.0 2.0]]
