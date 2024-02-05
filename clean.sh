
rm -rf HandRolled
rm -rf Products

git submodule update --init
cd cpython
git restore Mac/BuildScript/build-installer.py

