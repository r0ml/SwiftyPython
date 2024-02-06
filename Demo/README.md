
SwiftyPython
============

This project contains some samples to show how to use the SwiftyPython package.  SwiftyPython is a Swift Package Manager package which allows importing Python directly into a macOS swift application.  It supports having Swift call Python code, as well as Python code calling back into Swift code.

The demo includes SwiftyPython as a local package (located one directory up from the demo directory).  In your project, you would include SwiftyPython by providing the github URL to SwiftyPython.  This package only works on MacOS 

The samples demonstrated in this application use Python to:

1) use Numpy (for numerical and array manipulation)
2) use Boto (for managing AWS resources)
3) use Dominate (to generate HTML in Python)
4) run Matplotlib and capturing the resulting graphs as images in Swift
5) convert an image to an ascii image
6) download images from Bing 

========================



