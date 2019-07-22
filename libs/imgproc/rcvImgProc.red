Red [
	Title:   "Red Computer Vision: Image Processing"
	Author:  "Francois Jouen"
	File: 	 %rcvImgProc.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;updated version

#include %rcvImgProcRoutines.red


; ************ Color space conversions **********
; To be implemented or not?
; rcvColor src dst code 

rcvRGB2XYZ: function [
"RGB to CIE XYZ color conversion"
	src [image!] 
	dst [image!]
][
	_rcvXYZ src dst 1
] 

rcvBGR2XYZ: function [
"BGR to CIE XYZ color conversion"
	src [image!] 
	dst [image!]
][
	_rcvXYZ src dst 2
] 

rcvXYZ2RGB: function [
"CIE XYZ to RBG color conversion"
	src [image!] 
	dst [image!]
][
	_rcvXYZRGB src dst
] 


rcvRGB2HSV: function [
"RBG color to HSV conversion"
	src [image!] 
	dst [image!]
][
	_rcvHSV src dst 1
] 

rcvBGR2HSV: function [
"BGR color to HSV conversion"
	src [image!] 
	dst [image!]
][
	_rcvHSV src dst 2
] 

rcvRGB2YCrCb: function [
"RBG color to YCrCb conversion"
	src [image!] 
	dst [image!]
][
	_rcvYCrCb src dst 1
] 

rcvBGR2YCrCb: function [
"BGR color to YCrCb conversion"
	src [image!] 
	dst [image!]
][
	_rcvYCrCb src dst 2
]

rcvRGB2HLS: function [
"RBG color to HLS conversion"
	src [image!] 
	dst [image!]
][
	_rcvHLS src dst 1
] 

rcvBGR2HLS: function [
"BGR color to HLS conversion"
	src [image!] 
	dst [image!]
][
	_rcvHLS src dst 2
]

rcvRGB2Lab: function [
"RBG color to CIE L*a*b conversion"
	src [image!] 
	dst [image!]
][
	_rcvLab src dst 1
] 

rcvBGR2Lab: function [
"BGR color to CIE L*a*b conversion"
	src [image!] 
	dst [image!]
][
	_rcvLab src dst 2
]

rcvRGB2Luv: function [
"RBG color to CIE L*u*v conversion"
	src [image!] 
	dst [image!]
][
	_rcvLuv src dst 1
] 

rcvBGR2Luv: function [
"BGR color to CIE L*u*v conversion"
	src [image!] 
	dst [image!]
][
	_rcvLuv src dst 2
]

rcvIRgBy: function [
"log-opponent conversion"	
	src [image!] 
	dst [image!] 
	val [integer!]
][
	_rcvIRgBy src dst val
]
; ************ image transform **********

rcvFlip: function [
"Left Right, Up down or both directions flip"
	src [image!] 
	dst [image!] 
	/horizontal /vertical /both 
][
	case [
		horizontal 	[_rcvFlipHV src dst 1]
		vertical 	[_rcvFlipHV src dst 2]
		both		[_rcvFlipHV src dst 3]
	]	
]


rcvGlass: function [
"Glass effect on image"
	src [image!] 
	dst [image!] 
	v	[float!] ; random value
	op	[integer!]
][
	_rcvEffect src dst v op
]


rcvSwirl: function [
"Glass effect on image"
	src 	[image!] 
	dst 	[image!] 
	theta	[float!]
][
	_rcvEffect src dst theta 6
]


rcvWaveH: function [
"Glass effect on image"
	src 	[image!] 
	dst 	[image!] 
	alpha	[float!]
	beta	[float!]
][
	_rcvWave src dst alpha beta 1
]

rcvWaveV: function [
"Glass effect on image"
	src 	[image!] 
	dst 	[image!] 
	alpha	[float!]
	beta	[float!]
][
	_rcvWave src dst alpha beta 2
]





; ********** image intensity and blending ******************

rcvSetIntensity: function [
"Sets image intensity"
	src [image!] 
	dst [image!] 
	alpha	[float!]
][
	_rcvMathF src dst alpha 3
]	

rcvBlend: function [
"Mixes 2 images"
	src1 	[image!] 
	src2 	[image!] 
	dst  	[image!] 
	alpha	[float!]
][	
	_rcvBlend src1 src2 dst alpha ;OK for macOS 
]

;Specific version for Windows until rcvBlend problem solved
rcvBlendWin: function [
"Mixes 2 images"
	src1 	[image!] 
	src2 	[image!] 
	dst 	[image!] 
	alpha	[float!]
][	 
	img1: rcvCreateImage src1/size
	img2: rcvCreateImage src2/size
	_rcvMathF src1 img1 alpha 3
	_rcvMathF src2 img2 1.0 - alpha 3
	_rcvMath img1 img2 dst 1
	rcvReleaseImage img1
	rcvReleaseImage img2
	
]



; ********* Image Convolution **********

{The 2D convolution operation isn't extremely fast, 
unless you use small filters. We'll usually be using 3x3 or 5x5 filters. 
There are a few rules about the filter:
Its size has to be uneven, so that it has a center, for example 3x3, 5x5, 7x7 or 9x9 are ok. 
Apart from using a kernel matrix, convolution operation also has a multiplier factor and a bias. 
After applying the filter, the factor will be multiplied with the result, and the bias added to it. 
So if you have a filter with an element 0.25 in it, but the factor is set to 2, all elements of the filter 
are  multiplied by two so that element 0.25 is actually 0.5. 
The bias can be used if you want to make the resulting image brighter. 
}


rcvConvolve: function [
"Convolves an image with the kernel"
	src 	[image!] 
	dst 	[image!] 
	kernel 	[block!] 
	factor 	[float!] 
	delta 	[float!]
][
	_rcvConvolve src dst kernel factor delta
]

rcvFastConvolve: function [
"Convolves a 8-bit and 1-channel image with the kernel"
	src 	[image!] 
	dst 	[image!] 
	channel [integer!] 
	kernel 	[block!] 
	factor 	[float!] 
	delta 	[float!]
][
	_rcvFastConvolve src dst channel kernel factor delta
]

rcvFilter2D: function [
"Basic convolution Filter"
	src 	[image!] 
	dst 	[image!] 
	kernel 	[block!]  
	factor 	[float!] 
	delta 	[float!]
][
	_rcvFilter2D src dst kernel factor delta
]
	
rcvFastFilter2D: function [
"Faster convolution Filter"
	src 	[image!] 
	dst 	[image!] 
	kernel 	[block!]
] [
	_rcvFastFilter2D src dst kernel
]

; ********** spatial filters **************************

rcvPointDetector: function [
"Detects points"
	src 	[image! vector!] 
	dst 	[image! vector!] 
	param1 	[float!] 
	param2 [float!]
][
	knl: [-1.0 -1.0 -1.0 -1.0 8.0 -1.0 -1.0 -1.0 -1.0] ; OK
	t: type? src
	if t = vector! [
		_rcvConvolveMat src dst 3x3 knl param1 param2
	]
	if t = image! [
		_rcvConvolve src dst knl param1 param2
	]
]

rcvSharpen: function [
"Image sharpening"
	src 	[image! vector!] 
	dst 	[image! vector!] 
	iSize 	[pair!] 
] [
	
	knl: [0.0 -1.0 0.0 -1.0 5.0 -1.0 0.0 -1.0 0.0] ; OK
	t: type? src
	if t = vector! [
		_rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		_rcvConvolve src dst knl 1.0 0.0
	]
]

rcvBinomialFilter: function [
"Binomial filter"
	src 	[image! vector!] 
	dst 	[image! vector!] 
	iSize 	[pair!]  
	f 		[float!]
][
	ff: negate f * (1.0 / 16.0)
	knl: reduce [ff 2.0 * ff ff 2.0 * ff (16 - f) * (1.0 / 16.0)  2.0 * ff ff 2.0 * ff ff]
	t: type? src
	if t = vector! [
		_rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		;_rcvConvolve src dst knl 0.0 0.0
		_rcvFilter2D src dst knl 1.0 0.0
	]
]



;Uniform Weight Convolutions
; Blurring is typical of low pass filters

rcvLowPass: function [
"This filter produces a simple average of the 9 nearest neighbors of each pixel in the image."
	src 	[image! vector!] 
	dst 	[image! vector!] 
	iSize 	[pair!]
][
	v: 1.0 / 9.0 ; since weights is  > zero 
	knl: reduce [v v v v v v v v v]
	t: type? src
	if t = vector! [
		_rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		_rcvConvolve src dst knl 1.0 0.0
	]
]

;Non-Uniform (Binomial) Weight Convolution
rcvBinomialLowPass: function [
"Weights are formed from the coefficients of the binomial series."
	src 	[image! vector!] 
	dst 	[image! vector!] 
	iSize 	[pair!]
][
	l: 1.0 / 16.0; ; since weights is > zero
	knl: reduce [1.0 2.0 1.0 2.0 4.0 2.0 1.0 2.0 1.0]
	t: type? src
	if t = vector! [
		_rcvConvolveMat src dst iSize knl l 0.0
	]
	if t = image! [
		_rcvConvolve src dst knl l 0.0
	]
]

;shows the edges in the image
rcvHighPass: function [
"This filter produces a simple average  of the 9 nearest neighbors of each pixel in the image."
	src 	[image! vector!] 
	dst 	[image! vector!] 
	iSize 	[pair!]
][
	knl: [-1.0 -1.0 -1.0 -1.0 8.0 -1.0 -1.0 -1.0 -1.0]
	t: type? src
	if t = vector! [
		_rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		_rcvConvolve src dst knl 1.0 0.0
	]
]

;subtraction of low pass from original image 
rcvHighPass2: function [
"This filter removes low pass values from original image."
	src 	[image! vector!] 
	dst 	[image! vector!] 
	iSize 	[pair!]
][
	knl: [-1.0 -1.0 -1.0 -1.0 8.0 -1.0 -1.0 -1.0 -1.0]
	t: type? src
	if t = vector! [
		_rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		tmp1: rcvCreateImage src/size
		rcvLowPass src tmp1 src/size;  same as rcvGaussianFilter src tmp1
		rcvSub src tmp1 dst
	]
]

;Non-Uniform (Binomial) Weight Convolutions
rcvBinomialHighPass: function [
"Non-Uniform (Binomial) Weight Convolution"
	src 	[image! vector!] 
	dst 	[image! vector!] 
	iSize 	[pair!]
][
	knl: [-1.0 -2.0 -1.0 -2.0 12.0 -2.0 -1.0 -2.0 -1.0]
	t: type? src
	if t = vector! [
		_rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		_rcvConvolve src dst knl 1.0 0.0
	]
]

; for gaussian filters
rcvMakeGaussian: function [
"Creates a gaussian uneven kernel"
	kSize 	[pair!]
	sigma	[float!]
][
  gaussian: copy []
  n: kSize/x - 1 / 2
  i: negate n
  j: negate n
  sum: 0.0
  r: 0.0
  s: 2.0 * (sigma * sigma)
  while [j <= n] [
  	i: negate n
  	while [i <= n] [
  		r: square-root (i * i) + (j * j)
  		k: exp  ((negate(r * r) / s) / (pi * s))
  		append gaussian k
  		sum: sum + k
  		i: i + 1
  	]
  	j: j + 1
  ]
  ; now normalize the kernel
  i: 0
  while [i < (kSize/x * kSize/y)] [
  	gaussian/(i + 1): gaussian/(i + 1) / sum
  	i: i + 1
  ] 
  gaussian	
]

;new provisoire
_rcvMakeGaussian2: function [
"Creates a gaussian uneven kernel with different variance"
kSize [pair!] "Uneven Kernel size (e.g 3x3)"
sigma [float!] "Variance"
][
  gaussian: copy []
  n: kSize/x - 1 / 2
  j: negate n
  sum: 0.0
  while [j <= n] [
  	i: negate n
  	while [i <= n] [
  		r: negate (i * i) + (j * j)
  		s: 2 * (sigma * sigma)
  		g: exp  (r / s)
  		append gaussian g
  		sum: sum + g
  		i: i + 1
  	]
  	j: j + 1
  ]
  
  ; now normalize the kernel 
  i: 0
  while [i < (kSize/x * kSize/y)] [
  		gaussian/(i + 1): gaussian/(i + 1) / sum
  	i: i + 1
  ]
  gaussian	
]

; only for images
rcvGaussianFilter: function [
"Gaussian 2D Filter"
	src 	[image!] ;source image
	dst 	[image!] ;destination image
	kSize 	[pair!]	 ;kernel size
	sigma	[float!] ;variance
] [
	knl: rcvMakeGaussian kSize sigma
	_rcvFilter2D src dst knl 1.0 0.0
]

rcvDoGFilter: function [
"Difference of Gaussian"
	src 	[image! vector!] 
	dst 	[image! vector!]
	iSize	[pair!] 	 
	kSize	[pair!]  
	sig1	[float!] 
	sig2	[float!] 
	factor 	[float!] 
][
	k1: rcvMakeGaussian kSize sig1
	k2: rcvMakeGaussian kSize sig2
	len: kSize/x * kSize/y
	i: 1
	k: copy []
	while [i <= len] [
		v: k1/(i) - k2/(i)
		append k v
		i: i + 1
	]
	t: type? src
	if t =  image!  [_rcvConvolve src dst k factor 0.0]
	if t  = vector! [ _rcvConvolveMat src dst iSize k 1.0 0.0]
	
]


; median and mean filter for image smoothing

rcvMedianFilter: function [
"Median Filter for images"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!]
][	
	n: kSize/x * kSize/y
	kernel: make vector! n
	_rcvMedianFilter src dst kSize/x kSize/y kernel 0
]


rcvMinFilter: function [
"Minimum Filter for images"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!]
][	n: kSize/x * kSize/y
	kernel: make vector! n
	_rcvMedianFilter src dst kSize/x kSize/y kernel 1
]


rcvMaxFilter: function [
"Maximum Filter for images"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!]
][	
	n: kSize/x * kSize/y
	kernel: make vector! n
	_rcvMedianFilter src dst kSize/x kSize/y kernel 2
]

rcvNLFilter: function [
"Non linear conservative filter for images"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!]
][	
	n: kSize/x * kSize/y
	kernel: make vector! n
	_rcvMedianFilter src dst kSize/x kSize/y kernel 3
]

rcvMidPointFilter: function [
"Midpoint Filter for images"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!]
][	
	_rcvMidPointFilter src dst kSize/x kSize/y
]

rcvMeanFilter: function [
"Mean Filter for images"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!] 
	op 		[integer!]
][	
	;op = 0 arithmetic, 1 harmonic, 2 geometric mean
	;3 quadratic mean, 4 cubic mean, 5 rms
	_rcvMeanFilter src dst kSize/x kSize/y op
]


;***************** Fast edges detectors*******************

;First derivative filters

rcvKirsch: function [
"Computes an approximation of the gradient magnitude of the input image"
	src			[image! vector!] 
	dst			[image! vector!] 
	iSize 		[pair!] 
	direction 	[integer!] 
	op 			[integer!]
][
	k: [[-3.0 -3.0 5.0 -3.0 0.0 5.0 -3.0 -3.0 5.0]
		[5.0 -3.0 -3.0 5.0 0.0 -3.0 5.0 -3.0 -3.0]
		[-3.0 -3.0 -3.0 -3.0 0.0 -3.0 5.0 5.0 5.0]
		[5.0 5.0 5.0 -3.0 0.0 -3.0 -3.0 -3.0 -3.0]]
	
	switch op [
			1 [k1: k/1 k2: k/3]
			2 [k1: k/2 k2: k/4]
			3 [k1: k/1 k2: k/2]
			4 [k1: k/3 k2: k/4]
	]
	
	t: type? src
	if t = vector! [
		bitSize: (_rcvGetMatBitSize src) * 8
		mat1: rcvCreateMat 'integer! bitSize iSize
		mat2: rcvCreateMat 'integer! bitSize iSize
		mat3: rcvCreateMat 'integer! bitSize iSize
		_rcvConvolveMat src mat1 iSize k1 1.0 0.0
		_rcvConvolveMat src mat2 iSize k2 1.0 0.0
		switch direction [
				1 [rcvCopyMat mat1 dst] 	; X
				2 [rcvCopyMat mat2 dst]		; Y
				3 [mat3: mat1 + mat2 rcvCopyMat mat3 dst] ;  X and Y
				
		]
		rcvReleaseMat mat1
		rcvReleaseMat mat2
		rcvReleaseMat mat3
	]
	if t = image! [
		img1: rcvCreateImage iSize
		img2: rcvCreateImage iSize
		_rcvConvolve src img1 k1 1.0 0.0
		_rcvConvolve src img2 k2 1.0 0.0
		switch direction [
				1 [_rcvCopy img2 dst] ; HZ
				2 [_rcvCopy img1 dst]	; VT
				3 [rcvAdd img1 img2 dst] ; Both
				4 [_rcvMagnitude img1 img2 dst]
				5 [_rcvDirection img1 img2 dst] ; T= atan(Gx/gy)
		]
		rcvReleaseImage img1
		rcvReleaseImage img2
	]
]


rcvSobel: function [
"Direct Sobel Edges Detection"
	src 		[image! vector!]  
	dst 		[image! vector!] 
	iSize 		[pair!] 
	direction 	[integer!] 
	op 			[integer!]
][
	k: [[-1.0 -2.0 -1.0 0.0 0.0 0.0 1.0 2.0 1.0]
		[1.0 2.0 1.0 0.0 0.0 0.0 -1.0 -2.0 -1.0]
		[-1.0 0.0 1.0 0.0 0.0 0.0 -1.0 0.0 1.0]
		[1.0 0.0 -1.0 0.0 0.0 0.0 1.0 0.0 -1.0]]
		
	switch op [
			1 [k1: k/1 k2: k/3]
			2 [k1: k/2 k2: k/4]
			3 [k1: k/1 k2: k/2]
			4 [k1: k/3 k2: k/4]
	]
	
	t: type? src
	if t = vector! [
		bitSize: (_rcvGetMatBitSize src) * 8
		mat1: rcvCreateMat 'integer! bitSize iSize
		mat2: rcvCreateMat 'integer! bitSize iSize
		mat3: rcvCreateMat 'integer! bitSize iSize
		_rcvConvolveMat src mat1 iSize k1 1.0 0.0
		_rcvConvolveMat src mat2 iSize k2 1.0 0.0
		switch direction [
				1 [rcvCopyMat mat1 dst] 	; hx
				2 [rcvCopyMat mat2 dst]		; hy
				3 [mat5: mat1 + mat2 rcvCopyMat mat3 dst] ;  X and Y
		]
		rcvReleaseMat mat1
		rcvReleaseMat mat2
		rcvReleaseMat mat3
	]
	
	if t = image! [
		img1: rcvCreateImage iSize
		img2: rcvCreateImage iSize
		_rcvConvolve src img1 k1 1.0 0.0
		_rcvConvolve src img2 k2 1.0 0.0
		switch direction [
			1 [_rcvCopy img1 dst] ; HZ:Gx
			2 [_rcvCopy img2 dst]	; VT:Gy
			3 [rcvAdd img1 img2 dst] ; G = abs(Gx) + abs(Gy).
			4 [_rcvMagnitude img1 img2 dst] ; G= Sqrt Gx^2 +Gy^2
			5 [_rcvDirection img1 img2 dst] ; T= atan(Gx/gy)
		]
		rcvReleaseImage img1
		rcvReleaseImage img2
	]
]

rcvPrewitt: function [
"Computes an approximation of the gradient magnitude of the input image "
	src 		[image! vector!] 
	dst 		[image! vector!] 
	iSize 		[pair!] 
	direction 	[integer!] 
	op 			[integer!]
][
	{hx1: [-1.0 0.0 1.0 -1.0 0.0 1.0 -1.0 0.0 1.0]
	hx2: [1.0 0.0 -1.0 1.0 0.0 -1.0 1.0 0.0 -1.0]
	hy1: [-1.0 -1.0 -1.0 0.0 0.0 0.0 1.0 1.0 1.0]
	hy2: [1.0 1.0 1.0 0.0 0.0 0.0 -1.0 -1.0 -1.0]}
	
	k: [[-1.0 0.0 1.0 -1.0 0.0 1.0 -1.0 0.0 1.0]
		[1.0 0.0 -1.0 1.0 0.0 -1.0 1.0 0.0 -1.0]
		[-1.0 -1.0 -1.0 0.0 0.0 0.0 1.0 1.0 1.0]
		[1.0 1.0 1.0 0.0 0.0 0.0 -1.0 -1.0 -1.0]]
	
	switch op [
			1 [k1: k/1 k2: k/3]
			2 [k1: k/2 k2: k/4]
			3 [k1: k/1 k2: k/2]
			4 [k1: k/3 k2: k/4]
	]
	
	t: type? src
	if t = vector! [
		bitSize: (_rcvGetMatBitSize src) * 8
		mat1: rcvCreateMat 'integer! bitSize iSize
		mat2: rcvCreateMat 'integer! bitSize iSize
		mat3: rcvCreateMat 'integer! bitSize iSize
		_rcvConvolveMat src mat1 iSize k1 1.0 0.0
		_rcvConvolveMat src mat2 iSize k2 1.0 0.0
		switch direction [
				1 [rcvCopyMat mat2 dst] ; HZ
				2 [rcvCopyMat mat1 dst] ; VT
				3 [mat3: mat1 + mat2 rcvCopyMat mat3 dst]; Both
				
		]
		rcvReleaseMat mat1
		rcvReleaseMat mat2
		rcvReleaseMat mat3
	]
	if t = image! [
		img1: rcvCreateImage iSize
		img2: rcvCreateImage iSize
		_rcvConvolve src img1 k1 1.0 0.0
		_rcvConvolve src img2 k2 1.0 0.0
		switch direction [
				1 [_rcvCopy img2 dst] ; HZ
				2 [_rcvCopy img1 dst]	; VT
				3 [rcvAdd img1 img2 dst] ; Both
				4 [_rcvMagnitude img1 img2 dst]
				5 [_rcvDirection img1 img2 dst] ; T= atan(Gx/gy)
		]
		rcvReleaseImage img1
		rcvReleaseImage img2
	]
]

rcvMDIF: function [
"Computes an approximation of the gradient magnitude of the input image "
	src 		[image! vector!] 
	dst 		[image! vector!] 
	iSize 		[pair!] 
	direction 	[integer!]

][
	hx: [0.0 -1.0 0.0 1.0 0.0
		-1.0 -2.0 0.0 2.0 1.0
		-1.0 -3.0 0.0 3.0 1.0
		-1.0 -2.0 0.0 2.0 1.0
		0.0 -1.0 0.0 1.0 0.0
	]
	hy: [0.0 -1.0 -1.0 -1.0 0.0
		-1.0 -2.0 -3.0 -2.0 -1.0
		0.0 0.0 0.0 0.0 0.0
		1.0 2.0 3.0 2.0 1.0
		0.0 1.0 1.0 1.0 0.0
	]
	t: type? src
	if t = vector! [
		bitSize: (_rcvGetMatBitSize src) * 8
		mat1: rcvCreateMat 'integer! bitSize iSize
		mat2: rcvCreateMat 'integer! bitSize iSize
		mat3: rcvCreateMat 'integer! bitSize iSize
		_rcvConvolveMat src mat1 iSize hx 1.0 0.0
		_rcvConvolveMat src mat2 iSize hy 1.0 0.0
		switch direction [
				1 [rcvCopyMat mat2 dst] ; HZ
				2 [rcvCopyMat mat1 dst] ; VT
				3 [mat3: mat1 + mat2 rcvCopyMat mat3 dst]; Both
				
		]
		rcvReleaseMat mat1
		rcvReleaseMat mat2
		rcvReleaseMat mat3
	]
	if t = image! [
		img1: rcvCreateImage iSize
		img2: rcvCreateImage iSize
		rcvConvolve src img1 hx 1.0 0.0
		rcvConvolve src img2 hy 1.0 0.0
		switch direction [
				1 [_rcvCopy img2 dst] ; HZ
				2 [_rcvCopy img1 dst]	; VT
				3 [rcvAdd img1 img2 dst] ; Both
				4 [_rcvMagnitude img1 img2 dst]
				5 [_rcvDirection img1 img2 dst] ; T= atan(Gx/gy)
		]
		rcvReleaseImage img1
		rcvReleaseImage img2
	]
]


rcvRoberts: function [
"Robert's Cross Edges Detection"
	src 		[image! vector!] 
	dst 		[image! vector!] 
	iSize 		[pair!] 
	direction 	[integer!]
][
	h1: [0.0 1.0 -1.0 0.0]
	h2: [1.0 0.0 0.0 -1.0]
	t: type? src
	if t = vector! [
			bitSize: (_rcvGetMatBitSize src) * 8
			mat1: rcvCreateMat 'integer! bitSize iSize
			mat2: rcvCreateMat 'integer! bitSize iSize
			rcvConvolveMat src mat1 iSize h1 1.0 0.0
			rcvConvolveMat src mat2 iSize h2 1.0 0.0
			switch direction [
				1 [rcvCopyMat mat1 dst]
				2 [rcvCopyMat mat2 dst]
				3 [mat3: mat1 + mat2 rcvCopyMat mat3 dst]
			]
			rcvReleaseMat mat1
			rcvReleaseMat mat2	
			rcvReleaseMat mat3	
	]
	if t = image! [
			img1: rcvCreateImage iSize
			img2: rcvCreateImage iSize
			_rcvConvolve src img1 h1 1.0 0.0
			_rcvConvolve src img2 h2 1.0 0.0
			switch direction [
				1 [_rcvCopy img2 dst] ; HZ:Gx
				2 [_rcvCopy img1 dst]	; VT:Gy
				3 [rcvAdd img1 img2 dst] ; G = abs(Gx) + abs(Gy).
				4 [_rcvMagnitude img1 img2 dst] ; G= Sqrt Gx^2 +Gy^2
			]
			rcvReleaseImage img1
			rcvReleaseImage img2
	]
]

;TBD
rcvRobinson: function [
"Robinson Filter"
	src 	[image! vector!]
	dst 	[image! vector!]
	iSize 	[pair!] 
][
	knl: [1.0 1.0 1.0 1.0 -2.0 1.0 -1.0 -1.0 -1.0]
	t: type? src 
	if t = image!  [_rcvConvolve src dst knl 1.0 0.0]
	if t = vector! [_rcvConvolveMat src dst iSize knl 1.0 0.0]
]


;TBD
rcvGradientMasks: function [
"Fast gradient mask filter with 8 directions"
	src 		[image! vector!] 
	dst 		[image! vector!] 
	iSize 		[pair!] 
	direction 	[integer!]

][
	;"North" "Northeast" "East" "Southeast" "South" "Southwest" "West" "Northwest"
	gradientMasks: [
		[-1.0 -2.0 -1.0 0.0 0.0 0.0 1.0 2.0 1.0]
		[0.0 -1.0 -2.0 1.0 0.0 -1.0 2.0 1.0 0.0]
		[1.0 0.0 -1.0 2.0 0.0 -2.0 1.0 0.0 -1.0]
		[2.0 1.0 0.0 1.0 0.0 -1.0 0.0 -1.0 -2.0]
		[1.0 2.0 1.0 0.0 0.0 0.0 -1.0 -2.0 -1.0]
		[0.0 1.0 2.0 -1.0 0.0 1.0 -2.0 -1.0 0.0]
		[-1.0 0.0 1.0 -2.0 0.0 2.0 -1.0 0.0 1.0]
		[-2.0 -1.0 0.0 -1.0 0.0 1.0 0.0 1.0 2.0]
	]
	mask: gradientMasks/:direction
	t: type? src
	if t = image!  [rcvConvolve src dst mask 1.0 0.0]
	if t = vector! [rcvConvolveMat src dst iSize mask 1.0 0.0]
]

;TBD
rcvLineDetection: function [
"Fast line detection with 4 directions"
	src 		[image! vector!] 
	dst 		[image! vector!] 
	iSize 		[pair!] 
	direction 	[integer!]

][
	knl: [[-1.0 -1.0 -1.0 2.0 2.0 2.0 -1.0 -1.0 -1.0]
		  [-1.0 2.0 -1.0 -1.0 2.0 -1.0 -1.0 2.0 -1.0]
		  [2.0 -1.0 -1.0 -1.0 2.0 -1.0 -1.0 -1.0 2.0]
		  [-1.0 -1.0 2.0 -1.0 2.0 -1.0 2.0 -1.0 -1.0]]
	
	mask: knl/:direction
	t: type? src
	if t = image!  [rcvConvolve src dst mask 1.0 0.0]
	if t = vector! [rcvConvolveMat src dst iSize mask 1.0 0.0]
]

;only images
rcvGradNeumann: function [
"Computes the discrete gradient by forward finite differences and Neumann boundary conditions"
	src [image!] 
	d1  [image!] 
	d2  [image!]
][
	_rcvNeumann src d1 d2 1
]

rcvDivNeumann: function [
"Computes the divergence by backward finite differences"
	src [image!] 
	d1  [image!] 
	d2  [image!]
][
	_rcvNeumann src d1 d2 2
]


; Second derivative filter

rcvDerivative2: function [
"Computes the 2nd derivative of an image or a matrix"
	src 		[image! vector!] 
	dst 		[image! vector!] 
	iSize 		[pair!] 
	delta 		[float!] 
	direction 	[integer!]
][
	hx: [0.0 0.0 0.0 1.0 -2.0 1.0 0.0 0.0 0.0]
	hy: [0.0 1.0 0.0 0.0 -2.0 0.0 0.0 1.0 0.0]
	
	t: type? src
	if t = vector! [
		mat1: rcvCreateMat 'integer! 8 iSize
		mat2: rcvCreateMat 'integer! 8 iSize
		mat3: rcvCreateMat 'integer! 8 iSize
		_rcvConvolveMat src img1 iSize hx 1.0 delta
		_rcvConvolveMat src img1 iSize hy 1.0 delta
		switch direction [
			1 [rcvCopyMat mat1 dst]
			2 [rcvCopyMat mat2 dst]
			3 [mat3: mat1 + mat2 rcvCopyMat mat3 dst]
		]
		rcvReleaseMat mat1
		rcvReleaseMat mat2	
		rcvReleaseMat mat3
	]
	if t = image! [
		img1: rcvCreateImage iSize
		img2: rcvCreateImage iSize
		_rcvConvolve src img1 hx 1.0 delta
		_rcvConvolve src img2 hy 1.0 delta
		switch direction [
				1 [_rcvCopy img2 dst] ; HZ:Gx
				2 [_rcvCopy img1 dst] ; VZ:GY
				3 [rcvAdd img1 img2 dst] X+Y
		]
		rcvReleaseImage img1
		rcvReleaseImage img2
	]
]



rcvLaplacian: function [
"Computes the Laplacian of an image or a matrix"
	src 		[image! vector!] 
	dst 		[image! vector!] 
	iSize 		[pair!] 
	connexity 	[integer!]
] [
	if connexity = 4  [knl: [0.0 -1.0 0.0 -1.0 4.0 -1.0 0.0 -1.0 0.0]]
	if connexity = 8  [knl: [-1.0 -1.0 -1.0 -1.0 8.0 -1.0 -1.0 -1.0 -1.0]]
	if connexity = 16 [knl: [-1.0 0.0 0.0 -1.0 0.0 1.0 1.0 0.0 0.0 1.0 1.0 0.0 -1.0 0.0 0.0 -1.0 ]]
	t: type? src
	if t = vector! [_rcvConvolveMat src dst iSize knl 1.0 128.0]
	if t = image! [_rcvConvolve src dst knl 1.0 128.0]
]

;TBD
rcvDiscreteLaplacian: function [
"Discrete Laplacian Filter"
	src 	[image! vector!] 
	dst 	[image! vector!]
	iSize 	[pair!]

][
	knl: [1.0 1.0 1.0 1.0 -8.0 1.0 1.0 1.0 1.0]
	t: type? src
	if t = image! 	[_rcvConvolve src dst knl 1.0 0.0]
	if t = vector! 	[_rcvConvolveMat src dst iSize knl 1.0 0.0]
]
;TBD
rcvLaplacianOfRobinson: function [
"Laplacian of Robinson Filter"
	src 	[image! vector!] 
	dst 	[image! vector!]
	iSize 	[pair!]
][
	knl: [1.0 -2.0 1.0 -2.0 4.0 -2.0 1.0 -2.0 1.0]
	t: type? src
	if t = image! 	[_rcvConvolve src dst knl 1.0 0.0]
	if t = vector! 	[_rcvConvolveMat src dst iSize knl 1.0 0.0]
]

;TBD
rcvLaplacianOfGaussian: function [
"Laplacian of Gaussian"
	src 	[image! vector!] 
	dst 	[image! vector!]
	iSize 	[pair!]
	op		[integer!]
][
	if op = 1 [knl: [0.0 -1.0 0.0 -1.0 4.0 -1.0 0.0 -1.0 0.0]]
	if op = 2 [
	knl: [0.0 0.0 -1.0 0.0 0.0
		  0.0 -1.0 -2.0 -1.0 0.0
		  -1.0 -2.0 16.0 -2.0 -1.0
		  0.0 -1.0 -2.0 -1.0 0.0
		  0.0 0.0 -1.0 0.0 0.0	
		]
	]
	t: type? src
	if t = image! 	[_rcvConvolve src dst knl 1.0 0.0]
	if t = vector! 	[_rcvConvolveMat src dst iSize knl 1.0 0.0]
]

; A REVOIR
rcvKuwahara: function [
" non-linear smoothing filter"
	src 	[image! vector!] 
	dst 	[image! vector!]
	iSize 	[pair!]
][
	{knl: [1.0 1.0 1.0 2.0 2.0
		  1.0 1.0 1.0 2.0 2.0
		  4.0 4.0 0.0 2.0 2.0
		  4.0 4.0 3.0 3.0 3.0
		  4.0 4.0 3.0 3.0 3.0
		]}
		
	knl: [-0.5 1.5 -0.5
		 1.5 -3.0 1.5
		-0.5 1.5 -0.5
	]
	
	
	t: type? src
	if t = image! 	[_rcvConvolve src dst knl 1.0  0.0]
	if t = vector! 	[_rcvConvolveMat src dst iSize knl 1.0 0.0]
]



;******************* tools for Canny edges detection *****************
; ONLY GRAYSCALE IMAGE
rcvEdgesGradient: function [
"Image gradients with hypot function"
	srcX 	[image!] 
	srcY 	[image!] 
	mat		[vector!]

][
	_rcvEdgesGradient srcX srcY mat
]

rcvEdgesDirection: function [
"Angles in degrees with atan2 functions"
	srcX [image!] 
	srcY [image!] 
	matA [vector!]
][
	_rcvEdgesDirection srcX srcY matA
]

rcvEdgesSuppress: function [
"Non-maximum suppression"
	matA 	[vector!] 
	matG 	[vector!] 
	matS 	[vector!] 
	mSize	[pair!]
][
	_rcvEdgesSuppress matA matG matS mSize
]
rcvDoubleThresh: function [
"Double thresholding"
	gradS 	[vector!] 
	doubleT [vector!] 
	lowT 	[integer!]  
	highT 	[integer!] 
	lowV 	[integer!]  
	highV [integer!]
][
	_doubleThresholding gradS doubleT lowT highT lowV highV
]

rcvHysteresis: function [
"non-maximum suppression to thin out the edges"
	doubleT [vector!] 
	edges 	[vector!] 
	iSize 	[pair!]
	weak 	[integer!]  
	strong 	[integer!]
][
	_hysteresis doubleT edges iSize weak strong
]

;********************** Integral Images ****************************

rcvIntegral: function [
"Calculates integral images"
	src 	[image! vector!] 
	sum 	[image! vector!] 
	sqsum 	[image! vector!] 
	mSize 	[pair!]
][
	t: type? src
	if t = image!  [_rcvIntegral src sum sqsum]
	if t = vector! [_rcvIntegralMat src sum sqsum msize]
]


rcvProcessIntegralImage: function [
"Gets boxes in integral image"
	src 	[image! vector!] 
	w 		[integer!] 
	h 		[integer!] 
	boxW [	integer!] 
	boxH 	[integer!] 
	thresh	[integer!] 
	points 	[block!]
][
	t: type? src
	if t = vector! [_rcvProcessIntegralMat src w h boxW boxH thresh points] 
]


;******************* Image Transformations *****************************

__rcvResizeImage: function [
"Resizes image and applies filter for Gaussian pyramidal resizing if required"
	src [image!] 
	canvas 
	iSize [pair!]
	/Gaussian return: [pair!]
][
	tmpImg: rcvCloneImage src
	case [
		gaussian [
			knl: rcvMakeGaussian 5x5
			_rcvFilter2D tmpImg src knl 1.0 0.0
		]
	]
	rcvReleaseImage tmpImg
	canvas/size: iSize
	src: to-image canvas
	src/size
]
;modified

rcvResizeImage: function [
"Resizes image and applies filter for Gaussian pyramidal resizing if required"
	src 	[image!] 
	iSize 	[pair!] 
	/Gaussian 
][
	tmpImg: rcvCloneImage src
	case [
		gaussian [
			knl: rcvMakeGaussian 5x5
			_rcvFilter2D tmpImg src knl 1.0 0.0
		]
	]
	rcvReleaseImage tmpImg
	_rcvResize src iSize/x iSize/y
]



rcvScaleImage: function [
"Returns a Draw block for image scaling"
	factor [float!] 
	img [image!] 
][
	compose [scale (factor) (factor) image (img)]
]

rcvRotateImage: function [
"Returns a Draw block for image rotation"
	scaleValue 		[float!] 
	translateValue 	[pair!] 
	angle 			[float!] 
	center 			[pair!]  
	img 			[image!]
][
	compose [scale (scaleValue) (scaleValue) translate (translateValue) rotate (angle) (center) image (img)]
]

rcvTranslateImage: function [
"Returns a Draw block for image translation"
	scaleValue 		[float!] 
	translateValue 	[pair!] 
	img 			[image!]
][
	compose [scale (scaleValue) (scaleValue) translate (translateValue) image (img)]
]

rcvSkewImage: function [
"Returns a Draw block for image transformation"
	scaleValue 		[float!] 
	translateValue 	[pair!] 
	x 				[number!] 
	y 				[number!] 
	img 			[image!] 
][
	compose [scale (scaleValue) (scaleValue) translate (translateValue) skew (x) (y) image (img)]
]


rcvClipImage: function [
"Returns a Draw block for image clipping"
	translateValue 	[pair!] 
	start 			[pair!] 
	end 			[pair!] 
	img 			[image!]  
][
	compose [translate (translateValue) clip (start) (end) image (img)]
]

;********************** morphological operators *****************************************

rcvCreateStructuringElement: function [
"The function  allocates and fills a block, which can be used as a structuring element in the morphological operations"
	kSize [pair!] 
	/rectangle /cross
][
	element: copy []
	cols: kSize/x
	rows: kSize/y
  	i: 1
  	j: 1
  	case [
  		rectangle [
  			i: j: 1
  			while [j <= rows] [
  				while [i <= cols] [
  					append element 1 
  					i: i + 1
  				]
  				i: 1
  				j: j + 1
  			]
  		]
  		cross [
  			i: j: 1
  			while [i <= (rows * cols)] [append element 0 i: i + 1]
  			cx: cols / 2 
  			cy: rows / 2 
  			i: 0
  			j: 0
  			while [j < rows] [
  				while [i < cols] [
  					idx: (j * cols) + i + 1
  					if (i = cx) [element/(idx): 1]
  					if (j = cy) [element/(idx): 1]
  					i: i + 1
  				]
  				i: 0
  				j: j + 1
  			]
  		]
  	]
  	element
]

rcvErode: function [
"Erodes image by using structuring element"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!] 
	kernel 	[block!]
][
	_rcvErode src dst kSize/x kSize/y kernel
]

rcvDilate: function [
"Dilates image by using structuring element"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!] 
	kernel 	[block!]
][
	_rcvDilate src dst kSize/x kSize/y kernel 
]


rcvOpen: function [
"Erodes and Dilates image by using structuring element"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!] 
	kernel 	[block!]
] [
	_rcvErode src dst kSize/x kSize/y kernel 
	_rcvCopy dst src
	_rcvDilate src dst kSize/x kSize/y kernel
]


rcvClose: function [
"Dilates and Erodes image by using structuring element"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!] 
	kernel 	[block!]
] [
	_rcvDilate src dst kSize/x kSize/y kernel 
	_rcvCopy dst src
	_rcvErode src dst kSize/x kSize/y kernel 
]

rcvMGradient: function [
"Performs advanced morphological transformations using erosion and dilatation as basic operations"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!] 
	kernel 	[block!] 
	/reverse
][
	img1: rcvCloneImage src
	img2: rcvCloneImage src
	_rcvDilate src img1 kSize/x kSize/y kernel 
	_rcvErode src img2 kSize/x kSize/y kernel 
	either reverse [rcvSub img2 img1 dst] [rcvSub img1 img2 dst]
]

rcvTopHat: function [
"Performs advanced morphological transformations using erosion and dilatation as basic operations"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!] 
	kernel 	[block!]
][
	img1: rcvCloneImage src
	rcvOpen src img1 kSize kernel 
	rcvSub src img1 dst
]

rcvBlackHat: function [
"Performs advanced morphological transformations using erosion and dilatation as basic operations"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!] 
	kernel 	[block!]
][
	img1: rcvCloneImage src
	rcvClose src img1 kSize kernel 
	rcvSub img1 src dst
]

rcvMMean: function [
"Means image by using structuring element"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!] 
	kernel 	[block!]
][
	_rcvMMean src dst kSize/x kSize/y kernel
]


; Hough Transform

; *************** functions and functions that call routines ***************************

rcvMakeHoughAccumulator: func [
"Creates Hough accumulator"
	w [integer!] 
	h [integer!]
][
	either h > w [maxRho: ((sqrt 2.0) * h) / 2.0] 
				 [maxRho: ((sqrt 2.0) * w) / 2.0]
	accuH: to-integer maxRho * 2 ; -r .. +r
	accuW: 180 ; for theta
	make vector! accuH * accuW
]

rcvGetAccumulatorSize: function [
"Gets Hough space accumulator size"
	acc [vector!]
][
	accuW: 180
	n: length? acc
	accuH:  n / accuW
	as-pair accuW accuH
]

rcvHoughTransform: function [
"Makes Hough Space transform"
	mat 	[vector!] 
	accu 	[vector!] 
	w 		[integer!]  
	h 		[integer!] 
][
	_rcvHoughTransform mat accu w h 127 ; treshold
]


rcvHough2Image: function [
"Makes Hough space as red image"
	mat 		[vector!] 
	dst 		[image!] 
	contrast 	[float!]
][
	_rcvHough2Image mat dst contrast
]


rcvGetHoughLines: func [
"Gets lines in the accumulator according to threshold"
	accu 		[vector!] 
	img 		[image!] 
	threshold 	[integer!] 
	lines 		[block!]
][
	_rcvGetHoughLines accu img threshold lines
]


; new function for Gaussian noise on image 
rcvImageNoise: function [
"Generates Gaussian noise"
	src 	[image!] 
	noise 	[float!] 
	t 		[tuple!]
][
	_rcvGenerateNoise src noise t
]







