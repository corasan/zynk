//
//  ProjectView.swift
//  EASManager
//
//  Created by Henry on 8/24/24.
//

import SwiftUI

struct ProjectView: View {
    @EnvironmentObject var eas: EAS
    @EnvironmentObject var envsModel: EnvVariablesModel
    @AppStorage("lastOpenedProjectPath") var lastOpenedProjectPath: String = ""
    @AppStorage("lastOpenedProfileName") var lastOpenedProfileName = ""
    @State var selectedProfile: Profile?
    @State var isProjectSelected: Bool = false
    @State var profileName: String = ""
    
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading) {
                List(eas.profiles, selection: $selectedProfile) { profile in
                    NavigationLink(value: profile) {
                        Text(profile.name)
                    }
                }
                .onChange(of: selectedProfile, initial: true) { oldVal, newVal in
                    profileName = newVal?.name ?? ""
                    envsModel.profileName = profileName
                }
            }
        } detail: {
            if !eas.profiles.isEmpty, let profile = selectedProfile {
                VStack(alignment: .leading, spacing: 16) {
                    ProfileDetailsView(profile: profile)
                    EnvVariablesTable()
                }
                .onAppear {
                    setProfileNameAndSelectedProfile(profiles: eas.profiles)
                    AppCommands.addProjectToRecent(eas.projectPath)
                }
            }
            if eas.profiles.isEmpty {
                OpenProjectView()
            }
            if eas.profiles.isEmpty && eas.cliPath.isEmpty {
                Text("EAS CLI path not found")
            }
        }
        .navigationTitle(eas.projectName.capitalized)
        .toolbar {
            ToolbarItemGroup(placement: .confirmationAction) {
                Menu {
                    Button("Build iOS", action: { build(.ios) })
                    Button("Build Android", action: {  build(.android) })
                    Button("Build all", action: { build() })
                } label: {
                    Label("Build", systemImage: "hammer")
                        .labelStyle(.iconOnly)
                }
                Menu {
                    Button("Update iOS", action: { update(.ios) })
                    Button("Update Android", action: { update(.android)})
                    Button("Update all", action: { update() })
                } label: {
                    Label("Update", systemImage: "icloud.and.arrow.up")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .onAppear {
            if !eas.projectPath.isEmpty {
                eas.loadSecurityScopedBookmark()
            }
            setProfileNameAndSelectedProfile(profiles: eas.profiles)
        }
        .onChange(of: eas.profiles) { oldValue, newValue in
            setProfileNameAndSelectedProfile(profiles: newValue)
        }
    }
    
    func build(_ platform: EASPlatform = .all) {
        let name = selectedProfile?.name ?? ""
        eas.build(profile: name, platform: platform)
    }
    
    func update(_ platform: EASPlatform = .all) {
        let name = selectedProfile?.name ?? ""
        eas.update(profile: name, platform: platform)
    }
    
    func setProfileNameAndSelectedProfile(profiles: [Profile]) {
        if selectedProfile == nil, let firstProfile = profiles.first {
            selectedProfile = firstProfile
            profileName = firstProfile.name
            envsModel.profileName = firstProfile.name
        }
    }
}

#Preview {
    @Previewable @State var eas = EAS()
    @Previewable @State var envsModel = EnvVariablesModel()
    ProjectView()
        .environmentObject(eas)
        .environmentObject(envsModel)
}
