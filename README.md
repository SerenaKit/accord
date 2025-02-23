## Accord
A faster discord client for your Mac. 

### OS Requirement

Recommended: macOS Monterey
* Has Markdown support for messages
* Much more stable
* Fully tested

Minimum requirement: macOS Big Sur
* Untested
* Some features are missing
<sup>
If you want to help and have a macOS Big Sur device, PRs are welcomed
</sup>

### Installing

#### Homebrew [Recommended]
[If you have Homebrew installed on your Mac](https://brew.sh), you can get the latest Accord release by installing the `accord` package:
```
brew install --cask accord
```
To upgrade Accord using Homebrew, run the following:
```
brew upgrade --cask accord
```

#### GitHub Releases [Recommended]
Alternatively, you can [download the latest version of Accord via GitHub releases](https://github.com/evelyneee/accord/releases/latest). These builds will not receive automatic updates, so you will have to manually check for updates to benefit from the latest features and bug fixes.

#### TestFlight
[Install Accord via TestFlight](https://itunes.apple.com/us/app/testflight/id899247664?mt=8). This allows you to receive automatic updates, give feedback to the project, and stay up-to-date with changelogs. However, the TestFlight might be less updated.

### Building
Xcode is required.
1. Download the project and open it in Xcode 
2. In the project settings, select Signing & Capabilities tab, select your development team and input a new bundle id.
3. Open your terminal app and cd into the directory. 
4. Run `xcodebuild` 

The built product will be in the `build/Release` directory

### Licensing
This project is licensed under the BSD 4 clause license.

### Support
* If you have questions, feel free to [ask them in our Discord server](https://discord.gg/nUGnmA9yFH)!
* If you'd like to report an issue, [please do so here](https://github.com/evelyneee/accord/issues/new).
