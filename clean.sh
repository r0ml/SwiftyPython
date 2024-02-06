
rm -rf HandRolled
rm -rf Products
rm -rf cpython/Mac/BuildScript/seticon.app

git submodule update --init
cd cpython
git restore Mac/BuildScript/build-installer.py

