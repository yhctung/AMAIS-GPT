//
//  AskMeAnythingApp.swift
//  AskMeAnything
//
//  Created by Gradient Spaces on 5/27/24.
//

import SwiftUI

@main
struct AskMeAnythingApp: App {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some Scene {
        WindowGroup(id: "main"){
            AlternateView()
        }
        .defaultSize(width: 500, height: 700)
    }
    

}
