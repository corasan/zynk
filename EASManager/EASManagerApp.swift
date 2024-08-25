//
//  EASManagerApp.swift
//  EASManager
//
//  Created by Henry on 8/24/24.
//

import SwiftUI

class MyAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @AppStorage("lastOpenedProjectPath") var lastOpenedProjectPath: String = ""
    @Environment(\.openWindow) var openWindow

    func application(
        _ application: NSApplication
    ) {
        if !lastOpenedProjectPath.isEmpty {
            openWindow(id: "open-project")
        }
    }
}

@main
struct EASManagerApp: App {
    @State private var isProjectSelected = false
    @State private var profiles: [Profile] = []
    @State private var projectPath: URL?
    @AppStorage("lastOpenedProjectPath") var lastOpenedProjectPath: String = ""
    @StateObject var eas: EAS
    
    init() {
        let eas = EAS()
        _eas = StateObject(wrappedValue: eas)
    }
    
    var body: some Scene {
        WindowGroup {
            ProjectView()
                .frame(minWidth: 850, minHeight: 500)
                .environmentObject(eas)
            
        }
        
        .windowResizability(.contentSize)
        Window("Open Project", id: "open-project") {
            OpenProjectView(isProjectSelected: $isProjectSelected, profiles: $profiles, projectPath: $projectPath)
                .frame(minWidth: 360, minHeight: 220)
                .environmentObject(eas)
        }
        .windowResizability(.contentSize)
//
//        WindowGroup {
//            if isProjectSelected || !lastOpenedProjectPath.isEmpty {
//                ProjectView(projectPath: $projectPath, profiles: $profiles)
//                    .frame(minWidth: 850, minHeight: 500)
//            } else {
//                OpenProjectView(isProjectSelected: $isProjectSelected, profiles: $profiles, projectPath: $projectPath)
//                    .frame(minWidth: 350, minHeight: 200)
//                    .hidden()
//            }
//        }
//        .windowResizability(.contentSize)
    }
}
