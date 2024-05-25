Red [
    Title:   "Matrix tests "
    Author:  "Francois Jouen"
    File:    %normalizedMatrices.red
    Needs:   'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
;#include %../../libs/imgproc/rcvImgProc.red
#include %../../libs/imgproc/rcvConvolutionMat.red

;--laplacian convolution filter for sample
mask: [-1.0 0.0 -1.0 0.0 4.0 0.0 -1.0 0.0 -1.0]
isize: 256x256
bitSize: 32
;--create 3 images
img1: rcvCreateImage isize
img2: rcvCreateImage isize
img3: rcvCreateImage isize

loadImage: does [
    canvas1/image/rgb: black
    canvas2/image/rgb: black
    canvas3/image/rgb: black
    tmp: request-file
    unless none? tmp [
    	;--load and update images according to source image size
        img1: rcvLoadImage tmp
        img2: rcvCreateImage img1/size
        img3: rcvCreateImage img1/size
        ;--create 3 32-bit integer matrices
        mat1: matrix/init 2 bitSize img1/size
        mat2: matrix/init 2 bitSize img1/size
        mat3: matrix/init 2 bitSize img1/size
        ;--Converts to  grayscale image and to 1 Channel matrix [0..255]
        rcvImage2Mat img1 mat1
        ;--Standard Laplacian convolution                                    
        rcvConvolveMat mat1 mat2 mask 1.0 0.0 
        ;--Normalized Laplacian convolution          
        rcvConvolveNormalizedMat mat1 mat3 mask 1.0 0.0   
        ;--From matrices to Red images
        rcvMat2Image mat2 img2                                     
        rcvMat2Image mat3 img3     
        ;--show results and release matrices                             
        canvas1/image: img1
        canvas2/image: img2
        canvas3/image: img3
        rcvReleaseMat mat1
        rcvReleaseMat mat2
        rcvReleaseMat mat2
    ]
]


; ***************** Test Program ****************************
view win: layout [
        title "Matrix normalisation"
        button "Load" [loadImage]
        button 60 "Quit" [  rcvReleaseImage img1 
                            rcvReleaseImage img2
                            Quit]
        return
        text 100 "Source" pad 156x0 
        text 120 "Standard convolution"
        pad 136x0 
        text "Normalized convolution"
        return
        canvas1: base 256x256 img1
        canvas2: base isize img2
        canvas3: base isize img3
]