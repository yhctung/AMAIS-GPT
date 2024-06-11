//
//  AlternateView.swift
//  AskMeAnything
//
//  Created by Gradient Spaces on 5/27/24.
//

import SwiftUI
import PhotosUI
import RealityKit
import RealityKitContent
import Foundation
import Speech

struct AlternateView: View {
    
    // for general UI
    @State private var selectedTab = 1
    @State private var isShowingCamera = false
    @State private var isRecording = false
    @State private var isProcessing = false
    var states = ["Start", "Camera", "Select Photo", "Ask Question", "Response"]
    
    // for image selection
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: Image?
    @State private var selectedUIImage: UIImage? = nil
    
    // for user selection
    var users = ["Simple", "Professional"]
    @State private var selectedTone = "Simple"
    @State private var toneNote = "A straightforward response"
    
    // for length of response selection
    var length = ["Short", "Long"]
    @State private var selectedLength = "Short"
    
    // for GPT-4 response
    static var OPENAI_API_KEY = "" // REPLACE WITH YOUR API KEY
    @State private var prompt = "What is this?"
    @State var queryResponse: String?
    @State private var status = "No response yet"
    
    // for STT
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    // for TTS
    @State private var text: String = ""
    private var synthesizer = AVSpeechSynthesizer()
    
    // navigation bar
    /// title, back, next
    var navButtons: some View {
        HStack {
            Button(action: {
                print("Back")
                selectedTab = selectedTab - 1
            }, label: {
                Image(systemName: "arrow.left")
            }).disabled(selectedTab == 1)
            Spacer()
            Text(states[selectedTab-1])
                .font(.headline)
            Spacer()
            Button(action: {
                print("Next")
                selectedTab = selectedTab + 1
            }, label: {
                Image(systemName: "arrow.right")
            }).disabled(selectedTab == 5)
        }.frame(alignment: .top)
    }
    
    // start
    /// description, tone, length
    var startView : some View {
        VStack{
            navButtons
            
            Spacer()
            
            Text("Ask Me Anything").font(.largeTitle)
            Text("Select a photo, then record your question")
                .padding(20)
            
            Text("Pick your response tone")
                .font(.title2)
                .padding(1)
            HStack {
                ForEach(users, id: \.self) { option in
                    Button(action:{
                        self.selectedTone = option
                    }) {
                        Text(option)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 30) // Adjust width and height as needed
                            .background(selectedTone == option ? Color.gray.opacity(0.9) : Color.clear)
                            .cornerRadius(10)
                    }
                    .padding(1)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            Text(userNote)
                .onChange(of: selectedTone) {
                    userNote = (selectedTone == "Simple") ? "A straightforward response" : "A descriptive response with more context"
                }
                .font(.footnote)
                .padding(10)
            
            Text("Pick your response length")
                .font(.title2)
                .padding(1)
            HStack {
                ForEach(length, id: \.self) { option in
                    Button(action:{
                        self.selectedLength = option
                    }) {
                        Text(option)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 30) // Adjust width and height as needed
                            .background(selectedLength == option ? Color.gray.opacity(0.9) : Color.clear)
                            .cornerRadius(10)
                    }
                    .padding(1)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            Spacer()
        }
        .padding()
    }
    
    // Camera page
    /// alert, instructions
    var cameraView : some View {
        VStack {
            navButtons
            Spacer()
            
            Button(action: {
                self.isShowingCamera = true
            }) {
                HStack {
                    Image(systemName: "camera")
                    Text("Camera")
                }
            }
            .padding()
            .alert(isPresented: $isShowingCamera) {
                return Alert(title: Text("Camera Not Supported"), message: Text("Camera functionality is not available in visionOS. Take a picture with the Crown Button"), dismissButton: .default(Text("OK")))
            }
            VStack {
                Text("To take a picture:")
                    .padding()
                    .multilineTextAlignment(.leading)
                Text("1. Press left button 2x (Camera view -> take pic)")
                Text("2. Press right button 1x (return to app)")
                    .padding()
                Image(.avPbutton)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .padding()
            }
            Spacer()
        }
        .padding()
    }
    
    // Select photo page
    /// gallery, preview
    var photoView : some View {
        VStack {
            navButtons
            Spacer()
            
            selectedImage?
                .resizable()
                .aspectRatio(contentMode:.fit)
                .cornerRadius(10)
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Select Photo")
                }
            }
            Spacer()
        }
        .onChange(of: selectedItem) {
            Task {
                if let itemData = try? await selectedItem?.loadTransferable(type: Data.self){
                    selectedUIImage = UIImage(data: itemData)
                    selectedImage = Image(uiImage: selectedUIImage ?? UIImage())
                } else {
                    print("Failed to load image")
                }
            }
        }
        .padding()
    }
    
    // Ask question page
    /// record, stop, submit
    var questionView : some View {
        VStack{
            navButtons
            Spacer()
            
            selectedImage?
                .resizable()
                .aspectRatio(contentMode:.fit)
                .cornerRadius(10)
            
            Button(action: {
                isRecording.toggle()
            }) {
                HStack {
                    Image(systemName: self.isRecording ? "stop.circle" : "mic.circle")
                    Text(self.isRecording ? "Stop" : "Ask a Question")
                }
            }
            .padding()
            .onChange(of: isRecording) {
                if isRecording {
                    speechRecognizer.startTranscribing()
                } else {
                    speechRecognizer.stopTranscribing()
                }
            }
            
            Text(speechRecognizer.transcript)
            
            Spacer()
            HStack{
                Button("Submit"){
                    isRecording = false
                    isProcessing = true
                    performGPT4Request()
                }
                .disabled(isRecording || speechRecognizer.transcript.isEmpty)
            }
            if isProcessing{
                Text("Submitted")
            }
        }
        .onChange(of: selectedItem) {
            Task {
                if let itemData = try? await selectedItem?.loadTransferable(type: Data.self){
                    selectedUIImage = UIImage(data: itemData)
                    selectedImage = Image(uiImage: selectedUIImage ?? UIImage())
                } else {
                    print("Failed to load image")
                }
            }
        }
        .padding()
    }
    
    /// Response page
    var responseView : some View {
        VStack {
            navButtons
            Spacer()
            
            if queryResponse != nil || isProcessing {
                VStack{
                    Text("Answer Tone: " + selectedTone)
                        .multilineTextAlignment(.leading)
                    Text("Answer Length: " + selectedLength)
                        .multilineTextAlignment(.leading)
                    Text("Question: " + prompt)
                        .multilineTextAlignment(.leading)
                    
                    selectedImage?
                        .resizable()
                        .aspectRatio(contentMode:.fit)
                        .cornerRadius(10)
                }
            }
            HStack{
                Button(action: {
                    if synthesizer.isSpeaking {
                        synthesizer.pauseSpeaking(at: .immediate)
                    } else {
                        synthesizer.continueSpeaking()
                    }
                }) {
                    HStack {
                        Image(systemName: synthesizer.isSpeaking ? "pause.fill" : "play.fill")
                        Text(synthesizer.isSpeaking ? "Pause" : "Play")
                    }
                }
                .disabled(queryResponse == nil)
                .padding()
                
                Button(action :{
                    synthesizer.stopSpeaking(at: .immediate)
                    appReset()
                }) {
                    Text("Reset")
                }
            }
            .onChange(of: selectedItem) {
                Task {
                    if let itemData = try? await selectedItem?.loadTransferable(type: Data.self){
                        selectedUIImage = UIImage(data: itemData)
                        selectedImage = Image(uiImage: selectedUIImage ?? UIImage())
                    } else {
                        print("Failed to load image")
                    }
                }
            }
            
            VStack{
                Text("Response:")
                Text(status)
            }
            .onChange(of: queryResponse){
                if queryResponse != nil {
                    status = queryResponse!
                    speakText(queryResponse!)
                }
            }
            .onChange(of: isProcessing) {
                status = "Running"
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
    
    // MAIN VIEW -----------------------------------------------------------------------
    var body: some View {
        TabView(selection: $selectedTab){
            startView
            .tabItem {
                Label("Start", systemImage: "1.circle")
            }
            .tag(1)
            
            cameraView
            .tabItem {
                Label("Camera", systemImage: "2.circle")
            }
            .tag(2)
            
            photoView
            .tabItem {
                Label("Select Photo", systemImage: "3.circle")
            }
            .tag(3)
            
            questionView
            .tabItem {
                Label("Ask Question", systemImage: "4.circle")
            }
            .tag(4)
            
            responseView
            .tabItem {
                Label("Response", systemImage: "5.circle")
            }
            .tag(5)
        }
    }
    
    // FUNCTIONS -------------------------------------------------------------------
    
    // MISC UI
    /// returns image in base64
    func getJPEG() -> String? {
        if let data = selectedUIImage?.jpegData(compressionQuality: 1)
        {
            return data.base64EncodedString()
        } else{
            print("Error: Image not selected or jpeg not converted")
            return ""
        }
    }
    
    /// resets interface
    func appReset() {
        // for photo
        selectedItem = nil
        selectedImage = nil
        selectedUIImage = nil
        
        // for STT
        speechRecognizer.resetTranscript()
        
        // for GPT
        prompt = "What is this"
        queryResponse = nil
        isProcessing = false
        status = "No response yet"
        
        // for TTS
        synthesizer.stopSpeaking(at: .immediate)
        return
    }
    
    // SPEECH
    func getSTT() -> String {
        return speechRecognizer.transcript
    }
    
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        synthesizer.speak(utterance)
        print("Text to speak: \(text)")
        return
    }

    // GPT REQUESTS
    func performGPT4Request() {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid URL")
            return
        }
        
        if getSTT() != "" {
            prompt = getSTT()
        } else{
            print("Problem with STT transcript -> using default 'What is this'")
            prompt = "What is this"
            return
        }

        let tone = (selectedTone == "Simple") ? "general" : "descriptive"
        let length = (selectedLength == "Long") ? "medium" : "short"
        
        let textQuery = "You are an average person and you want to be " + tone + " and the answer should be " + length + ". Please answer " + prompt
        
        guard let base64Image = getJPEG() else{
            print("Failed to convert image to base64")
            return
        }
        
        let parameters: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
              [
                "role": "user",
                "content": [
                  [
                    "type": "text",
                    "text": textQuery
                  ],
                  [
                    "type": "image_url",
                    "image_url": [
                      "url": "data:image/jpeg;base64,\(base64Image)",
                      "detail": "high"
                    ]
                  ]
                ]
              ]
            ],
            "max_tokens": 300
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // TODO: add error handling (missing api key) here
        request.setValue("Bearer "+ OPENAI_API_KEY, forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to encode parameters: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making API request: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    // here is content -> update state variable (of type string) with this content
                    DispatchQueue.main.async {
                        self.queryResponse = content
                    }
                }
            } catch {
                print("Failed to decode JSON response: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}
