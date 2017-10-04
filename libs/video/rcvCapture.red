Red [
	Title:   "Red Computer Vision: Video Capture"
	Author:  "Francois Jouen"
	File: 	 %rcvCapture.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


#include %rcvCaptureRoutines.red

rcvCreateCam: function [device [integer!]
"Opens Camera device number (0 default cam)"
][
	createCam device
]

rcvSetCamSize: function [device [integer!] cSize [pair!]
"Sets cam size"
][
	w: to float! cSize/x
	h: to float! cSize/y
	setCamSize h w
]

rcvgetCamSize: function [device [integer!] return: [pair!]
"Gets cam size"
][
	cSize: 0x0
	cSize/x: to integer! getCamWidth
	cSize/y: to integer! getCamHeight
	cSize
]

rcvGetCamImage: function [device [integer!] img [image!]
"Gets cam immage"
][
	getCamImage img
]

