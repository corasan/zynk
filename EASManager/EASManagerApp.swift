//
//  EASManagerApp.swift
//  EASManager
//
//  Created by Henry on 8/24/24.
//

import SwiftUI

@main
struct EASManagerApp: App {
    @State private var isProjectSelected = false
    @State private var profiles: [Profile] = []
    @State private var projectPath: URL?
    
    var body: some Scene {
        WindowGroup {
            if isProjectSelected {
                ProjectView(projectPath: $projectPath, profiles: $profiles)
                    .frame(minWidth: 850, minHeight: 500)
            } else {
                OpenProjectView(isProjectSelected: $isProjectSelected, profiles: $profiles, projectPath: $projectPath)
                    .frame(minWidth: 350, minHeight: 200)
            }
        }
        .windowResizability(.contentSize)
    }
}
