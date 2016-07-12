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
"Create empty (black) image"
][
	make image! reduce [size black]
]

rcvReleaseImage: routine [src [image!]] [
"Delete image from memory"
	image/delete src
]

rcvLoadImage: function [fileName [file!] return: [image!]
"Load image from file"
] [
	load fileName
]

rcvLoadImageB: function [fileName [file!] return: [binary!] /alpha
"Load image from file and return image as binary"
] [
	tmp: load fileName
	either alpha [tmp/argb] [tmp/rgb]
]

rcvSaveImage: function [src [image!] fileName [file!]
"Save image to file"
][
	write/binary file src
]

rcvCloneImage: function [src [image!] return: [image!]
"Return a copy of source image"
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
rcvRandomImage: function [size [pair!] value [tuple!] /uniform /alea return: [image!]
"Create a random uniform or pixel random image"
][
	case [
		uniform [img: make image! reduce [size random value]]
		alea 	[img: make image! reduce [size black] forall img [img/1: random value ]]
	] 
	img
]

rcvZeroImage: function [src [image!]
"All pixels to 0"
][
	src/argb: black
]

{
rcvDecodeImage
rcvDecodeImageM
cvEncodeImage
}


