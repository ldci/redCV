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

rcvRGB2XYZ: function [src [image!] dst [image!]
"RGB to CIE XYZ color conversion"
] [
	_rcvXYZ src dst 1
] 

rcvBGR2XYZ: function [src [image!] dst [image!]
"BGR to CIE XYZ color conversion"
] [
	_rcvXYZ src dst 2
] 

rcvXYZ2RGB: function [src [image!] dst [image!]
"CIE XYZ to RBG color conversion"
] [
	_rcvXYZRGB src dst
] 


rcvRGB2HSV: function [src [image!] dst [image!]
"RBG color to HSV conversion"
] [
	_rcvHSV src dst 1
] 

rcvBGR2HSV: function [src [image!] dst [image!]
"BGR color to HSV conversion"
] [
	_rcvHSV src dst 2
] 

rcvRGB2YCrCb: function [src [image!] dst [image!]
"RBG color to YCrCb conversion"
] [
	_rcvYCrCb src dst 1
] 

rcvBGR2YCrCb: function [src [image!] dst [image!]
"BGR color to YCrCb conversion"
] [
	_rcvYCrCb src dst 2
]

rcvRGB2HLS: function [src [image!] dst [image!]
"RBG color to HLS conversion"
] [
	_rcvHLS src dst 1
] 

rcvBGR2HLS: function [src [image!] dst [image!]
"BGR color to HLS conversion"
] [
	_rcvHLS src dst 2
]

rcvRGB2Lab: function [src [image!] dst [image!]
"RBG color to CIE L*a*b conversion"
] [
	_rcvLab src dst 1
] 

rcvBGR2Lab: function [src [image!] dst [image!]
"BGR color to CIE L*a*b conversion"
] [
	_rcvLab src dst 2
]

rcvRGB2Luv: function [src [image!] dst [image!]
"RBG color to CIE L*u*v conversion"
] [
	_rcvLuv src dst 1
] 

rcvBGR2Luv: function [src [image!] dst [image!]
"BGR color to CIE L*u*v conversion"
] [
	_rcvLuv src dst 2
]

; ************ image transform **********

rcvFlip: function [src [image!] dst [image!] /horizontal /vertical /both return: [image!]
"Left Right, Up down or both directions flip"
][
	case [
		horizontal 	[_rcvFlipHV src dst 1]
		vertical 	[_rcvFlipHV src dst 2]
		both		[_rcvFlipHV src dst 3]
	]	
]

; ********** image intensity and blending ******************

rcvSetIntensity: function [src [image!] dst [image!] alpha	[float!]
"Sets image intensity"
][
	_rcvMathF src dst alpha 3
]	

rcvBlend: function [src1 [image!] src2 [image!] dst [image!] alpha	[float!]
"Mixes 2 images"
][	
	_rcvBlend src1 src2 dst alpha ;OK for macOS 
]

;Specific version for Windows until rcvBlend problem solved
rcvBlendWin: function [src1 [image!] src2 [image!] dst [image!] alpha	[float!]
"Mixes 2 images"
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


rcvConvolve: function [src [image!] dst [image!] kernel [block!] factor [float!] delta [float!]
"Convolves an image with the kernel"
] [
	_rcvConvolve src dst kernel factor delta
]

rcvFastConvolve: function [src [image!] dst [image!] channel [integer!] kernel [block!] factor [float!] delta [float!]
"Convolves a 8-bit and 1-channel image with the kernel"
] [
	_rcvFastConvolve src dst channel kernel factor delta
]

rcvFilter2D: function [src [image!] dst [image!] kernel [block!]  delta [integer!]
"Basic convolution Filter"
] [
	_rcvFilter2D src dst kernel delta
]
	
rcvFastFilter2D: function [src [image!] dst [image!] kernel [block!]
"Faster convolution Filter"
] [
	_rcvFastFilter2D src dst kernel
]

; ********** spatial filters **************************

rcvSharpen: function [src [image! vector!] dst [image! vector!] iSize [pair!] 
" "
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

rcvBinomialFilter: function [src [image! vector!] dst [image! vector!] iSize [pair!]  f [float!]
" "
] [
	ff: negate f * (1.0 / 16.0)
	knl: reduce [ff 2.0 * ff ff 2.0 * ff (16 - f) * (1.0 / 16.0)  2.0 * ff ff 2.0 * ff ff]
	t: type? src
	if t = vector! [
		_rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		;_rcvConvolve src dst knl 0.0 0.0
		_rcvFilter2D src dst knl 1.0
	]
]



;Uniform Weight Convolutions
; Blurring is typical of low pass filters

rcvLowPass: function [src [image! vector!] dst [image! vector!] iSize [pair!]
"This filter produces a simple average  of the 9 nearest neighbors of each pixel in the image."
] [
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
rcvBinomialLowPass: function [src [image! vector!] dst [image! vector!] iSize [pair!]
"Weights are formed from the coefficients of the binomial series."
] [
	l: 1.0 / 16.0; ; since weights is > zero
	knl: reduce [1.0 * l 2.0 * l 1.0 * l 2.0 * l 4.0 * l 2.0 * l 1.0 * l 2.0 * l 1.0 * l]
	t: type? src
	if t = vector! [
		_rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		_rcvConvolve src dst knl 1.0 0.0
	]
]

;shows the edges in the image
rcvHighPass: function [src [image! vector!] dst [image! vector!] iSize [pair!]
"This filter produces a simple average  of the 9 nearest neighbors of each pixel in the image."
] [
	v: -1.0
	knl: reduce [v v v v 8.0 v v v v]
	t: type? src
	if t = vector! [
		_rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		_rcvConvolve src dst knl 1.0 0.0
	]
]

;subtraction of low pass from original image 
rcvHighPass2: function [src [image! vector!] dst [image! vector!] iSize [pair!]
"This filter ."
] [
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
rcvBinomialHighPass: function [src [image! vector!] dst [image! vector!] iSize [pair!]
"Non-Uniform (Binomial) Weight Convolution"
] [
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

rcvMakeGaussian: function [kSize [pair!] return: [block!]
"Creates a gaussian uneven kernel"
][
  gaussian: copy []
  n: kSize/x - 1 / 2
  i: negate n
  j: negate n
  
  sum: 0.0
  stdv: 1.0
  r: s: 2.0 * (stdv * stdv)
  while [j <= n] [
  	while [i <= n] [
  		r: square-root (i * i) + (j * j)
  		append gaussian exp  ((negate(r * r) / s) / (pi * s))
  		sum: sum + exp  ((negate(r * r) / s) / (pi * s))
  		i: i + 1
  	]
  	i: negate n
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



rcvGaussianFilter: function [src [image!] dst [image!]
"Gaussian 2D Filter"
] [
	kernel: rcvMakeGaussian 3x3
	_rcvFilter2D src dst kernel 0
]



;***************** Fast edges detectors*******************

;First derivative filters

rcvKirsch: function [src [image! vector!] dst [image! vector!] iSize [pair!] direction [integer!]
"computes an approximation of the gradient magnitude of the input image"
][
	hx: [-3.0 -3.0 5.0 -3.0 0.0 5.0 -3.0 -3.0 5.0]
	hy: [3.0 -3.0 -3.0 -3.0 0.0 -3.0 5.0 5.0 5.0]
	t: type? src
	if t = vector! [
		bitSize: (_rcvGetMatBitSize src) * 8
		mat1: rcvCreateMat 'integer! bitSize iSize
		mat2: rcvCreateMat 'integer! bitSize iSize
		mat3: rcvCreateMat 'integer! bitSize iSize
		rcvConvolveMat src mat1 iSize hx 1.0 0.0
		rcvConvolveMat src mat2 iSize hy 1.0 0.0
		switch direction [
				1 [rcvCopyMat mat1 dst] 		; X
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
		rcvConvolve src img1 hx 1.0 0.0
		rcvConvolve src img2 hy 1.0 0.0
		switch direction [
				1 [_rcvCopy img2 dst] ; HZ
				2 [_rcvCopy img1 dst]	; VT
				3 [rcvAdd img1 img2 dst] ; Both
				4 [_rcvMagnitude img1 img2 dst]
		]
		rcvReleaseImage img1
		rcvReleaseImage img2
	]
]


rcvSobel: function [src [image! vector!]  dst [image! vector!] iSize [pair!] direction [integer!]
"Direct Sobel Edges Detection"
] [
	hx: [1.0 2.0 1.0 0.0 0.0 0.0 -1.0 -2.0 -1.0]
	hy: [1.0 2.0 -1.0 2.0 0.0 -2.0 1.0 -2.0 -1.0]
	ho: [0.0 1.0 2.0 -1.0 0.0 1.0 -2.0 -1.0 0.0]
	t: type? src
	if t = vector! [
		bitSize: (_rcvGetMatBitSize src) * 8
		mat1: rcvCreateMat 'integer! bitSize iSize
		mat2: rcvCreateMat 'integer! bitSize iSize
		mat3: rcvCreateMat 'integer! bitSize iSize
		mat4: rcvCreateMat 'integer! bitSize iSize
		_rcvConvolveMat src mat1 iSize hx 1.0 0.0
		_rcvConvolveMat src mat2 iSize hy 1.0 0.0
		_rcvConvolveMat src mat3 iSize ho 1.0 0.0
		switch direction [
				1 [rcvCopyMat mat1 dst] 	; X
				2 [rcvCopyMat mat2 dst]		; Y
				3 [rcvCopyMat mat3 dst]		; 0
				4 [mat4: mat1 + mat2 rcvCopyMat mat4 dst] ;  X and Y
				
		]
		rcvReleaseMat mat1
		rcvReleaseMat mat2
		rcvReleaseMat mat3
		rcvReleaseMat mat4
	]
	
	
	if t = image! [img1: rcvCreateImage iSize
		img2: rcvCreateImage iSize
		img3: rcvCreateImage iSize
		rcvConvolve src img1 hx 1.0 0.0
		rcvConvolve src img2 hy 1.0 0.0
		rcvConvolve src img3 ho 1.0 0.0
		switch direction [
			1 [_rcvCopy img1 dst] ; HZ:Gx
			2 [_rcvCopy img2 dst]	; VT:Gy
			3 [_rcvCopy img3 dst]	; Oblique
			4 [rcvAdd img1 img2 dst] ; G = abs(Gx) + abs(Gy).
			5 [_rcvMagnitude img1 img2 dst] ; G= Sqrt Gx^2 +Gy^2
		]
		rcvReleaseImage img1
		rcvReleaseImage img2
		rcvReleaseImage img3
	]
]

rcvPrewitt: function [src [image! vector!] dst [image! vector!] iSize [pair!] direction [integer!]
"computes an approximation of the gradient magnitude of the input image "
][
	hx: [-1.0 0.0 1.0 -1.0 0.0 1.0 -1.0 0.0 1.0]
	hy: [-1.0 -1.0 -1.0 0.0 0.0 0.0 1.0 1.0 1.0]
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
		]
		rcvReleaseImage img1
		rcvReleaseImage img2
	]
]


rcvRoberts: function [src [image! vector!] dst [image! vector!] iSize [pair!] direction [integer!]
"Robert's Cross Edges Detection"
] [
	hx: [0.0 1.0 -1.0 0.0]
	hy: [1.0 0.0 0.0 -1.0]
	t: type? src
	if t = vector! [
			bitSize: (_rcvGetMatBitSize src) * 8
			mat1: rcvCreateMat 'integer! bitSize iSize
			mat2: rcvCreateMat 'integer! bitSize iSize
			rcvConvolveMat src mat1 iSize hx 1.0 0.0
			rcvConvolveMat src mat2 iSize hy 1.0 0.0
			switch direction [
				1 [rcvCopyMat mat1 dst]
				2 [rcvCopyMat mat2 dst]
				3 [mat3: mat1 + mat2 rcvCopyMat mat3 dst]
			]
			rcvReleaseMat mat1
			rcvReleaseMat mat2	
			rcvReleaseMat mat2	
	]
	if t = image! [
			img1: rcvCreateImage iSize
			img2: rcvCreateImage iSize
			_rcvConvolve src img1 hx 1.0 0.0
			_rcvConvolve src img2 hy 1.0 0.0
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


rcvGradNeumann: function [src [image!] d1 [image!] d2 [image!]
"Computes the discrete gradient by forward finite differences and Neumann boundary conditions"
][
	_rcvNeumann src d1 d2 1
]

rcvDivNeumann: function [src [image!] d1 [image!] d2 [image!]
"Computes the divergence by backward finite differences"
][
	_rcvNeumann src d1 d2 2
]


; Second derivative filter

;test
rcvDerivative2: function [src [image! vector!] dst [image! vector!] iSize [pair!] factor [float!] direction [integer!]

"Computes the 2nd derivative of an image or a matrix"
] [
	hx: [0.0 0.0 0.0 1.0 2.0 1.0 0.0 0.0 0.0]
	hy: [0.0 1.0 0.0 0.0 -2.0 0.0 0.0 1.0 0.0]
	
	t: type? src
	if t = vector! [
		mat1: rcvCreateMat 'integer! 8 iSize
		mat2: rcvCreateMat 'integer! 8 iSize
		mat3: rcvCreateMat 'integer! 8 iSize
		_rcvConvolveMat src img1 iSize hx 1.0 factor
		_rcvConvolveMat src img1 iSize hy 1.0 factor
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
		_rcvConvolve src img1 hx 1.0 factor
		_rcvConvolve src img2 hy 1.0 factor
		switch direction [
				1 [_rcvCopy img2 dst] ; HZ:Gx
				2 [_rcvCopy img1 dst] ;
				3 [rcvAdd img1 img2 dst]
		]
		rcvReleaseImage img1
		rcvReleaseImage img2
	]
]



rcvLaplacian: function [src [image! vector!] dst [image! vector!] iSize [pair!] connexity [integer!]
"Computes the Laplacian of an image or a matrix"
] [
	if connexity = 4  [knl: [0.0 -1.0 0.0 -1.0 4.0 -1.0 0.0 -1.0 0.0]]
	if connexity = 8  [knl: [-1.0 -1.0 -1.0 -1.0 8.0 -1.0 -1.0 -1.0 -1.0]]
	if connexity = 16 [knl: [-1.0 0.0 0.0 -1.0 0.0 1.0 1.0 0.0 0.0 1.0 1.0 0.0 -1.0 0.0 0.0 -1.0 ]]
	t: type? src
	if t = vector! [
		_rcvConvolveMat src dst iSize knl 1.0 128.0
	]
	if t = image! [
			_rcvConvolve src dst knl 1.0 128.0
	]
]

;********************** Integral Images ****************************

rcvIntegral: function [src [image! vector!] sum [image! vector!] sqsum [image! vector!] mSize [pair!]
"Calculates integral images"
][
	t: type? src
	if t = image!  [_rcvIntegral src sum sqsum]
	if t = vector! [_rcvIntegralMat src sum sqsum msize]
]



;******************* Image Transformations *****************************

rcvResizeImage: function [src [image!] canvas iSize [pair!]/Gaussian return: [pair!]
"Resizes image and applies filter for Gaussian pyramidal resizing if required"
][
	tmpImg: rcvCloneImage src
	case [
		gaussian [
			knl: rcvMakeGaussian 5x5
			_rcvFilter2D tmpImg src knl 0
		]
	]
	rcvReleaseImage tmpImg
	canvas/size: iSize
	src: to-image canvas
	src/size
]


rcvScaleImage: function [factor [float!] img [image!] return: [block!]
"Returns a Draw block for image scaling"
][
	compose [scale (factor) (factor) image (img)]
]

rcvRotateImage: function [scaleValue [float!] translateValue [pair!] angle [float!] center [pair!]  img [image!] return: [block!]
"Returns a Draw block for image rotation"
][
	compose [scale (scaleValue) (scaleValue) translate (translateValue) rotate (angle) (center) image (img)]
]

rcvTranslateImage: function [scaleValue [float!] translateValue [pair!] img [image!] return: [block!]
"Returns a Draw block for image translation"
][
	compose [scale (scaleValue) (scaleValue) translate (translateValue) image (img)]
]

rcvSkewImage: function [scaleValue [float!] translateValue [pair!] x [number!] y [number!] img [image!] return: [block!]
"Returns a Draw block for image transformation"
][
	compose [scale (scaleValue) (scaleValue) translate (translateValue) skew (x) (y) image (img)]
]

;append version 0.6.2

rcvClipImage: function [translateValue [pair!] start [pair!] end [pair!] img [image!]  return: [block!]
"Returns a Draw block for image clipping"
][
	compose [translate (translateValue) clip (start) (end) image (img)]
]

;********************** morphological operators *****************************************

rcvCreateStructuringElement: function [kSize [pair!] return: [block!] /rectangle /cross
"The function  allocates and fills a block, which can be used as a structuring element in the morphological operations"
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

rcvErode: function [ src [image!] dst [image!] kSize [pair!] kernel [block!]
"Erodes image by using structuring element"
] [
	_rcvErode src dst kSize/x kSize/y kernel
]

rcvDilate: function [ src [image!] dst [image!] kSize [pair!] kernel [block!]
"Dilates image by using structuring element"
] [
	_rcvDilate src dst kSize/x kSize/y kernel 
]


rcvOpen: function [ src [image!] dst [image!] kSize [pair!] kernel [block!]
"Erodes and Dilates image by using structuring element"
] [
	img: rcvCloneImage dst
	_rcvErode src img kSize/x kSize/y kernel 
	_rcvDilate img dst kSize/x kSize/y kernel 
]

rcvClose: function [ src [image!] dst [image!] kSize [pair!] kernel [block!]
"Dilates and Erodes image by using structuring element"
] [
	img: rcvCloneImage dst
	_rcvDilate src img kSize/x kSize/y kernel 
	_rcvErode img dst kSize/x kSize/y kernel 
]

rcvMGradient: function [ src [image!] dst [image!] kSize [pair!] kernel [block!] /reverse
"Performs advanced morphological transformations using erosion and dilatation as basic operations"
] [
	img1: rcvCloneImage src
	img2: rcvCloneImage src
	_rcvDilate src img1 kSize/x kSize/y kernel 
	_rcvErode src img2 kSize/x kSize/y kernel 
	either reverse [rcvSub img2 img1 dst] [rcvSub img1 img2 dst]
]

rcvTopHat: function [ src [image!] dst [image!] kSize [pair!] kernel [block!]
"Performs advanced morphological transformations using erosion and dilatation as basic operations"
] [
	img1: rcvCloneImage src
	rcvOpen src img1 kSize kernel 
	rcvSub src img1 dst
]

rcvBlackHat: function [ src [image!] dst [image!] kSize [pair!] kernel [block!]
"Performs advanced morphological transformations using erosion and dilatation as basic operations"
] [
	img1: rcvCloneImage src
	rcvClose src img1 kSize kernel 
	rcvSub img1 src dst
]

rcvMMean: function [ src [image!] dst [image!] kSize [pair!] kernel [block!]
"Means image by using structuring element"
] [
	_rcvMMean src dst kSize/x kSize/y kernel
]







