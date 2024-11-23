//
//  EASManagerApp.swift
//  EASManager
//
//  Created by Henry on 8/24/24.
//

import SwiftUI

@main
struct ZynkApp: App {
    @State private var isProjectSelected = false
    @State private var profiles: [Profile] = []
    @State private var projectPath: URL?
    @State private var selectedProject: String = ""
    @State private var isShowingPicker = false
    @AppStorage("lastOpenedProjectPath") var lastOpenedProjectPath: String = ""
    @StateObject var eas: EAS
    @StateObject var envsModel: EnvVariablesModel
    private var recentlyOpenedProjects: [String] {
        UserDefaults.standard.stringArray(forKey: "recentlyOpenedProjects") ?? []
    }
    
    init() {
        let eas = EAS()
        let envsModel = EnvVariablesModel()
        _eas = StateObject(wrappedValue: eas)
        _envsModel = StateObject(wrappedValue: envsModel)
    }
    
    var body: some Scene {
        WindowGroup {
            ProjectView()
                .frame(minWidth: 850, minHeight: 500)
                .environmentObject(eas)
                .environmentObject(envsModel)
            
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
                            envsModel.reload()
                            AppCommands.addProjectToRecent(folder.relativePath)
                        }
                    case .failure(let error):
                        print("Error selecting folder: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        Settings {
            SettingsView()
        }
    }
}
