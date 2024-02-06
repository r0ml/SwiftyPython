
#####################################################
# any app has to have "disable library validation" checked -- since the .so files are not signed.
#####################################################

/bin/ls *.so | xargs -I xx codesign -s '9EL3' xx

#####################################################################

