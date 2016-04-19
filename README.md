# FetLife for iOS

Welcome to the official FetLife iOS open-source client! :confetti_ball: We're excited to start developing our iOS app as an open-source project and allowing the community to engage and contribute.

## Getting started

The app is still a major work in progress. The goal is to take the base FetLife chat application and add more features and API endpoints to match the other features on fetlife.com.

The current operating system target of the application is iOS 9.0 or higher.

#### Building the application

To run and use the app, it must be built locally and run on your device or the iOS simulator from Xcode.

1. Download and install the latest [Xcode developer tools](https://developer.apple.com/xcode/download/) from Apple.
- Install [CocoaPods](https://cocoapods.org/).
- Clone the [repository](https://github.com/fetlife/fetlife-ios).

  ```
  git clone git@github.com:fetlife/fetlife-ios.git
  cd fetlife-ios
  ```
- Install the project's dependencies.

  ```
  pod install
  ```
- Open the project by clicking on the `FetLife.xcworkspace` file or using the command line.

  ```
  open FetLife.xcworkspace
  ```
- Build the `FetLife` scheme in Xcode. The app can be run within a simulator or [on a device](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/LaunchingYourApponDevices/LaunchingYourApponDevices.html).

If you find a bug or want to contribute, please start by reading through the [GitHub issues](https://github.com/fetlife/fetlife-ios/issues) and [contributing](https://github.com/fetlife/fetlife-ios/blob/master/CONTRIBUTING.md) guidelines.

## Screenshots

![](https://cloud.githubusercontent.com/assets/171215/14657660/d67be15c-0654-11e6-8f8e-937476c98a60.png)

## License

FetLife for iOS is released under the [MIT License](http://www.opensource.org/licenses/MIT).
