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
struct ZynkApp: App {
    @State private var isProjectSelected = false
    @State private var profiles: [Profile] = []
    @State private var projectPath: URL?
    @AppStorage("lastOpenedProjectPath") var lastOpenedProjectPath: String = ""
    @StateObject var eas: EAS
    @StateObject var secretsManager: SecretsManager
    @State private var selectedProject: String = ""
    @State private var isShowingPicker = false
    private var recentlyOpenedProjects: [String] {
        UserDefaults.standard.stringArray(forKey: "recentlyOpenedProjects") ?? []
    }
    
    init() {
        let eas = EAS()
        let secretsManager = SecretsManager()
        _eas = StateObject(wrappedValue: eas)
        _secretsManager = StateObject(wrappedValue: secretsManager)
    }
    
    var body: some Scene {
        WindowGroup {
            ProjectView()
                .frame(minWidth: 850, minHeight: 500)
                .environmentObject(eas)
                .environmentObject(secretsManager)
            
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Open...", action: {
                    let recent = UserDefaults.standard.stringArray(forKey: "recentlyOpenedProjects") ?? []
                    print("Recent: \(recent)")
                    isShowingPicker.toggle()
                })
                .fileImporter(
                    isPresented: $isShowingPicker,
                    allowedContentTypes: [.directory],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let folders):
                        if let folder = folders.first {
                            eas.saveSecurityScopedBookmark(for: folder)
                            eas.projectPath = folder.path
                            lastOpenedProjectPath = folder.path
                            eas.readEASJson()
                            eas.readAppJson()
                            secretsManager.reload()
                            AppCommands.addProjectToRecent(folder.relativePath)
                        }
                    case .failure(let error):
                        print("Error selecting folder: \(error.localizedDescription)")
                    }
                }
//                Picker(selection: $selectedProject, label: Text("Open Recent")) {
//                    ForEach(recentlyOpenedProjects, id: \.self) { path in
//                        Button(path, action: {
//                            eas.projectPath = path
//                            lastOpenedProjectPath = path
//                            eas.readEASJson()
//                            eas.readAppJson()
//                            secretsManager.reload()
//                        })
//                        .tag(path)
//                    }
//                }
            }
        }
    }
}
