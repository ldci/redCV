Red [
	Title:   "Red Computer Vision: Image Codecs"
	Author:  "Francois Jouen"
	File: 	 %rcvImage.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


rcvCreateImage: function [size [pair!] return: [image!]
"Create empty (black) image "
][
	make image! reduce [size black]
]

rcvReleaseImage: routine [src [image!]] [
	image/delete src
]

rcvLoadImage: function [fileName [file!] return: [image!]
"load image from file"
] [
	load fileName
]

rcvLoadImageB: function [fileName [file!] return: [binary!] /alpha
"load image from file and return Mat as binary"
] [
	tmp: load fileName
	either alpha [tmp/argb] [tmp/rgb]
]

rcvSaveImage: function [src [image!] fileName [file!]/bmp /png /jpg
"save image to file"
][
; TBD
]

rcvCloneImage: function [src [image!] return: [image!]
"Returns a copy of src image"
] [
	dst: make image! reduce [src/size black]
	rcvCopy src dst
	dst
]
rcvCopyImage: function [src [image!] dst [image!]
"Copy source image to destination image"
][
	rcvCopy src dst
]

; OK nice but /alea very slow Must be improved
rcvRandomImage: function [size [pair!] value [tuple!] /uniform /alea return: [image!]][
	case [
		uniform [img: make image! reduce [size random value]]
		alea 	[img: make image! reduce [size black] forall img [img/1: random value ]]
	] 
	img
]

{
rcvDecodeImage
rcvDecodeImageM
cvEncodeImage
}


