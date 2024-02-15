#  SwiftyPython

This is a Swift Package Manager package to easily embed Python in a Mac app.  Work is currently underway to have a package which will work on other Apple platforms as well.  This package is "universal", meaning it should work with intel or amd hardware.

To add Python an app, simply include the SwiftyPython package.  This should expose two Swift modules which can be imported.  One is `PythonSupport` -- which is a Swifty interface to invoke Python code from Swift.  The other is `PythonWrapper` which provides direct access to the Python C API from Swift.

The package currently comes bundled with (in addition to the standard library): 

 - certifi
 - numpy
 - pillow
 - boto3
 - matplotlib

This list is easily extensible.

In addition to these built-in packages, one can provide a `requirements.txt` file in the app including SwiftyPython, and those files will be installed into a virtual environment for the app as part of its build process.  This package includes a demo app (Demo) which demonstrates how to use SwiftyPython.  The Demo app includes SwiftyPython as a "local" package -- you should use the githb URL instead.

The Mac app which import SwiftyPython should have a folder called `venv`.  The PYTHONPATH will include `venv` and `venv/site-packages` (where the `requirements.txt` will install packages).


## Building an app using SwiftyPython

- If you enable hardened runtime, you have to disable library validation.
- You have to disable user script sandboxing in XCode to allow pip to install into venv/site-packages

## Known problems

Although I collect the Python standard output, in the Demo app, it is currently logged to the console, and not displayed in the "stdout" window.
