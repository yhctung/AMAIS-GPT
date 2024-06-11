# AMAIS-GPT 
<img align="left" src="AskMeAnything/AskMeAnything/Assets.xcassets/AppIcon.solidimagestack/Front.solidimagestacklayer/Content.imageset/ItunesArtwork@2x.png" width=100><br>
**AMAIS-GPT** (Ask Me Anything Intelligent System - GPT) is a VisionOS app that queries the environment using pictures. 


[![Swift Version][swift-image]][swift-url]
[![GPT Version][gpt-image]][gpt-url]
<br clear="left"/>

## Screenshot
![AppStartPage](https://github.com/steinargr/CEE342/assets/42920413/cc267329-280c-45b3-a4cc-203f7bbe5b03)

## Features

The following functionality is completed:

- [x] User can launch a "camera view" to take pictures using Siri or the physical crown button.
- [x] User can ask a question and see the live transcription
- [x] User can receive a response from GPT via text
- [x] User can reset/cancel during or after the task
- [x] User can play and pause audio
- [x] User can listen to the response
- [x] Show a description of what the response tone actually means for the task
- [x] User receives alert when launching camera informing about limitations
- [x] Improve navigation interface using TabView

Additional features are planned:

- [ ] Add accessibility support for VoiceOver annotations
- [ ] Style or animate status text, or display a loading bar for better usability
- [ ] Limit audio recording time to prevent poor GPT response
- [ ] Reduce size of image to speed up GPT response

Stretch goals:

- [ ] User can place text or audio response in the real world using anchors
- [ ] Image/question/response is saved in database for future review
- [ ] User can gesture towards items in the physical space and receive information (semantic map, etc)

## Demo
[![Demo Video](https://img.youtube.com/vi/lSpds7mvRBo/0.jpg)](https://www.youtube.com/watch?v=lSpds7mvRBo)

## Installation
1. Download project files and open AskMeAnything folder in XCode (version >= 15.2 on Apple device with M1/M2/M3 chip).
2. Verify XCode/app permissions for microphone and speech recognition access.
- Check Info.plist via XCode default app permissions for “Privacy - Microphone Usage Description” and “Privacy - Speech Recognition Usage Description”. Add if not present.
3. Replace OPENAI_API_KEY in `AlternateView.swift` with your API key.
4. Run app in the XCode simulator or deploy and run on your Apple Vision Pro.

## References

- [Speech to Text](https://developer.apple.com/tutorials/app-dev-training/transcribing-speech-to-text) - Record and transcribe audio
- [PhotosPicker](https://www.hackingwithswift.com/quick-start/swiftui/how-to-let-users-select-pictures-using-photospicker) - Selecting and displaying image
- [TabView](https://www.hackingwithswift.com/books/ios-swiftui/creating-tabs-with-tabview-and-tabitem) - Setting up TabView
- [App Icon](https://www.iconikai.com/generate-icon) - AI generated app icon
- [README Template](https://github.com/awesome-labs/swift-readme-template)
- [Martin Bucher](https://github.com/mnbucher) - coding help
  
[swift-image]:https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white
[swift-url]: https://swift.org/
[gpt-image]:https://img.shields.io/badge/ChatGPT-74aa9c?style=for-the-badge&logo=openai&logoColor=white
[gpt-url]:https://chatgpt.com
