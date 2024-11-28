#!/usr/local/bin/red
Red [
]

#include %../matrix-obj.red
matrix/show mx: matrix/create 2 32 3x3 [1 2 3 4 5 6 7 8 9]
print [pad "Product: " 10  matrix/product mx]
print [pad "Sum: " 10 matrix/sigma mx]
print [pad "Mean: " 10 matrix/mean mx]
print [pad "Mini: " 10 matrix/mini mx]
print [pad "Maxi: " 10 matrix/maxi mx]