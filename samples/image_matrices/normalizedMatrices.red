Red [
    Title:   "Matrix tests "
    Author:  "Francois Jouen"
    File:    %normalizedMatrices.red
    Needs:   'View
]

#include %../../libs/redcv.red ; for redCV functions
; laplacian convolution filter for sample
mask: [-1.0 0.0 -1.0 0.0 4.0 0.0 -1.0 0.0 -1.0]
isize: 512x512
bitSize: 32
img1: rcvCreateImage isize
img2: rcvCreateImage isize
img3: rcvCreateImage isize

loadImage: does [
    canvas1/image/rgb: black
    canvas2/image/rgb: black
    canvas3/image/rgb: black
    tmp: request-file
    if not none? tmp [
        img1: rcvLoadImage tmp
        img2: rcvCreateImage img1/size
        img3: rcvCreateImage img1/size
        mat1: rcvCreateMat 'integer! bitSize img1/size
        mat2: rcvCreateMat 'integer! bitSize img1/size
        mat3: rcvCreateMat 'integer! bitSize img1/size
        ; Converts to  grayscale image and to 1 Channel matrix [0..255]
        rcvImage2Mat img1 mat1  
        ; Standard Laplacian convolution                                    
        rcvConvolveMat mat1 mat2 img1/size mask 1.0 0.0 
        ; Normalized Laplacian convolution          
        rcvConvolveNormalizedMat mat1 mat3 img1/size mask 1.0 0.0   
        ; From matrices to Red images
        rcvMat2Image mat2 img2                                      
        rcvMat2Image mat3 img3      
        ; show results                              
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
        title "Laplacian convolution on matrix"
        button "Load" [loadImage]
        button 60 "Quit" [  rcvReleaseImage img1 
                            rcvReleaseImage img2
                            Quit]
        return
        text 100 "Source" pad 156x0 
        text 120 "Standard convolution"
        pad 392x0 
        text "Normalized convolution"
        return
        canvas1: base 256x256 img1
        canvas2: base isize img2
        canvas3: base isize img3
]