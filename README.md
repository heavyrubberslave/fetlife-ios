# FetLife for iOS

Welcome to FetLife's open-source iOS app!

### Current Features

- View a list of your conversations
- Read and respond to conversations


### Requirements to run the app on your iPhone

- iPhone running iOS 9.0 or higher
- Mac running OS X 10.11 or later


### Screenshots of the App

![Screenshots of iOS App from a iPhone 6](https://cloud.githubusercontent.com/assets/22100/14684831/a0d2c0c4-06e6-11e6-8d9a-177caf8cb410.png)


### Installing the App on your iPhone for the first time

These instructions are written assuming you know very little about computers and to help get the app on your iPhone as quickly as possible:

1. Install the latest version of [Xcode](https://itunes.apple.com/ca/app/xcode/id497799835?mt=12).
2. Open the `Terminal` application up on your Mac.
3. Enter the following commands into your terminal window one by one and wait for them to finish:
  - `sudo gem install cocoapods` you will be prompted for your computers password
  - `git clone git@github.com:fetlife/fetlife-ios.git`
  - `cd fetlife-ios`
  - `pod install`
  - `open FetLife.xcworkspace`
4. Installing the app on your phone:
  - Connect your iPhone to your computer.
  - Select your iPhone from the "[Scheme toolbar menu](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/Art/5_launchappondevice_2x.png)".
  - Click the "Run" button.
  - If an error occurs saying the Bundle Identifier is unavailable, change the Bundle Identifier to something unique in Xcode and try again please.
5. Follow the instructions in the pop up windows i.e.:
  - Click "Fix Issue".
  - Enter in the username and password for your iCloud account.
  - "Select a Development Team" i.e your own name.
  - *You will probably have to do that 7-8 times*
  - Unlock your phone so your Mac can install the app onto your phone.
6. Trust your own developer on your iDevice under "Settings -> General -> Profile -> (your apple ID)"
7. Do the [happy dance](https://www.youtube.com/watch?v=Ckt5JgshnaA)! :-)


### Kinksters Helping Kinksters

Want to install the app on your phone but are not technically savvy? Ask your local kinky geek! Technically savvy and want to give back to the community... bring your laptop with you the next time you attend an event and install / update the app for anyone who's interested in having it install on their iPhone. *#KinkstersHelpingKinksters*


### Got Bugs?

If you find a bug please start by reading through the our current list of [open issues](https://github.com/fetlife/fetlife-ios/issues) and if you can't find anything about your bug please [submit a new bug](https://github.com/fetlife/fetlife-ios/issues/new).


### Want to Contribute

Woot woot! Please checkout our [Contributing Guidelines](https://github.com/fetlife/fetlife-ios/blob/master/CONTRIBUTING.md) and go from there.

### Frequently Asked Questions

- **Is a Mac required to install the application?** Yes, a Mac computer with at least OS X 10.11 or later is required to run the app and install it on a device.


### License

FetLife for iOS is released under the [MIT License](http://www.opensource.org/licenses/MIT).
