Red [
	Title:   "Red Computer Vision: Color Space"
	Author:  "Francois Jouen"
	File: 	 %rcvColorSpace.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


; ************ Color space conversions **********
rcvRGB2XYZ: function [src [image!] dst [image!]] [
	rcvRGBXYZ src dst
] 

rcvXYZ2RGB: function [src [image!] dst [image!]] [
	rcvXYZRGB src dst
] 

; to be continued
