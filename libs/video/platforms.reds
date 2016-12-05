Red/System [
	Title:		"OpenCV 3.0.0 Binding"
	Author:		"F.Jouen"
	Rights:		"Copyright (c) 2015-2016 F.Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]



#define CV_CAP_PROP_POS_MSEC 0
#define CV_CAP_PROP_POS_FRAMES 1
#define CV_CAP_PROP_POS_AVI_RATIO 2
#define CV_CAP_PROP_FRAME_WIDTH 3
#define CV_CAP_PROP_FRAME_HEIGHT 4
#define CV_CAP_PROP_FPS 5

;inline functions
; great with Red 0.31 we can define macros!!!
#define CV_FOURCC(c1 c2 c3 c4) [(((((as integer! c1)) and 255) + (((as integer! c2) and 255) << 8) + (((as integer! c3) and 255) << 16) + (((as integer! c4) and 255) << 24)))]


; adapt libraries paths for your own use :)
#switch OS [
    MacOSX  [
        #define cvVideocapture "/usr/local/lib32/xcode/libcameraLib.dylib"
    ]
    Windows [
        #define cvVideocapture "c:\opencv310\build\x86\mingw\cameraLib.dll"
    ]
    Linux   [
        #define cvVideocapture ""
    ]
]

#define importMode cdecl

#import [
    cvVideocapture importMode [
    	openCamera: "openCamera"[
    	"Open Camera"
    	    index   [integer!]
    	    return: [integer!]
        ]
        releaseCamera: "releaseCamera" [
        "Release Camera"
        ]
        
        setCameraProperty: "setCameraProperty" [
        "Set Camera property"
            propId  [integer!]
            value   [float!]
            return: [integer!]
        ]
        
        getCameraProperty: "getCameraProperty" [
        "Get Camera property"
            propId  [integer!]
            return: [float!]
        ]
        
        readCamera: "readCamera"[
        "Read camera frame"
            return: [integer!]
        ]
        
        grabFrame: "grabFrame" [
        "Grab frame"
            return: [integer!]
        ]
        
        retrieveFrame: "retrieveFrame"[
        "Retrieve grabbed image"
            flag    [integer!] ;int=0
            return: [integer!]
        ]
        openFile: "openFile" [
        "Open video file"
            filename    [c-string!]
            return:     [integer!]
        ]
        
    ]; end rcvVideocapture
]; end import
