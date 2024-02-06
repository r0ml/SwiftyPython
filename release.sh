

cd HandRolled
zip -r Python.xcframework.zip Python.xcframework
swift package compute-checksum Python.xcframework.zip | xargs -I '{}' sed -I '' 's/\(checksum: "\).*\("\)/\1{}\2/' ../Package.swift
