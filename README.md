# Computer Vision with Red Language 
## see http://www.red-lang.org 
### This library needs View 


Only for Windows for the moment. Available for OSX and Linux ASAP.

#### You need the lastest Red master version.

Developped under Mac OSX 10.12

Tested with Windows XP and Windows 10.

You must compile samples since red routines are required.

### NEW OCTOBER 10 2016

rcvScaleImage, rcvTranslateImage and rcvRotateImage are now RedCV Functions.

See RedCV_Manual for details.

Samples and documentation updated.


### NEW OCTOBER 10 2016

Scale, Translate and Rotate operators based on Red Draw Dialect added.

New convolution samples added.


### NEW OCTOBER 5 2016

RedCV Reference Manual replaces basic documentation.

About 150 functions tested and are functional.


### NEW SEPTEMBER 29 2016

New color space conversions added.

rcvInRange function added: Extracts sub array from image according to lower and upper rgb values.

Samples and documentation updated.

### NEW SEPTEMBER 25 2016

Histogram functions for matrices and color images added.

New samples added.

Doc updated.

### NEW SEPTEMBER 21 2016

Statistical functions are rewritten to be used with images and matrices.

rcvMinLoc and rcvMaxLoc functions added: Finds global minimum or maximum location in array.

Doc updataed.

### NEW SEPTEMBER 19 2016

Split and Merge functions for matrices are added.


### NEW SEPTEMBER 12 2016
A lot of optimized functions for working with 8,16 and 32-bit integer matrices.

New samples added.

Documentation updated.

### NEW SEPTEMBER 1 2016
Image resizing and Gaussian Pyramid Decomposition are added with this function: 

rcvResizeImage: function [src [image!] canvas iSize [pair!]/gaussian return: [pair!]]

Only Gaussian 5x5 kernel is currently supported. Canvas is a base facet.If you don’t call /Gaussian refinement image is just resized by Red.
Documentation updated.


### NEW AUGUST 29 2016

Convolution with integer matrices is now possible. 

Also added  a faster rcvFastConvolve working on separate image channel or grayscaled images. 


### NEW AUGUST 24 2016

Back from summer break with a lot of new samples and functions!

Matrices can be used now with vector! datatype, but we'll wait for the matrix! datatype for improving functions.

New samples folder thematic organization.

Doc is updated.


### NEW JULY 27 2016

gaussianFilter sample updated.


### NEW JULY 26 2016

Slight changes in libs: all red routines begin with underscore (e.g. _rcvCopy).

Documentation updated.

Samples updated.   

New samples added in /samples/test directory.


### NEW July 24 2016

A sample for Gaussian Filter


### NEW July 23 2016

Gaussian filter added (see /samples/test/ testGaussian.red)


### NEW July 18 2016

Convolve routines are improved but rather low speed as expected!

2D Filtering can be used. (see documentation for details)

More samples to come

### NEW July 12 2016

Fast flip render and documentation update

### NEW july 10 2016

#### Documentation for redCV functions added

### NEW july 9 2016

Black and white image filter added.

A new sample (motion.red) for motion tracking with webcam.


### NEW: July 8 2106
A lot of work for this new version with faster routines and functions

Most of functions are in the form rcvFunction [src [image!] dst [image!]] [....]
This avoids memory leaks due to image copy 

New organizations for libs 

All Red/System Routines are in the same file and routines are exported as red functions in the various libs

New basic samples (to be compiled) 

Documentation and new samples will be included ASAP


### NEW: June 28 2016

rcvFlip routines are faster (written in Red/System).

Motion detection sample added : you can use your webcam to do a video monitoring!

Samples are compiled with -t WindowsXP option.


### NEW: June 22 2016
Libs are improved for faster routines.

New convolution samples are included.

Rendering duration is calculated with the new Red timer and sent back to the user.

Special thanks for DideC for interface improvment:)

New folder organisation:

/samples for red code
/samples/_exe for exec files


### NEW: June 17 2016

Convolution routines for images are added.

More to come ...


### NEW: June 15 2016
Added statistical functions on image.

Added some space color conversion.

More to come...


### NEW: June 2016
After playing a long time with OpenCV and Red language, it's time for me to write some image processing functions directly with Red:)

Conversions, logical and some math operators for images are available.


According to KISS spirit of Red, you only need  to include one file in your code : #include %libs/redcv.red.(See opimage.red sample for detail).

This file includes Red Functions and calls all necessary routines. 

More functions and samples to come!

You'll find some images to play within images folder. All supported images by Red can be used.

Special thanks to Nenad for developing Red, and to Qingtian for image implementation.


##Please feel free to contribute and enjoy :)
