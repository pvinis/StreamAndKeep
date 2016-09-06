Compile
=

carthage update --platform "iOS"
cd Carthage/Checkouts/lf.swift
pod install
cd -
carthage build --platform "iOS"

no sound on recorded video
