Compile
=

carthage update --platform "iOS"
cd Carthage/Checkouts/lf.swift
pod install
cd -
carthage build --platform "iOS"

replace streamInfo with correct uri and stream name
