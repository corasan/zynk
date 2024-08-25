//
//  ProjectView.swift
//  EASManager
//
//  Created by Henry on 8/24/24.
//

import SwiftUI

struct ProjectView: View {
    @Binding var projectPath: URL?
    @Binding var profiles: [Profile]

    @State private var selectedProfile: Profile?
    @StateObject private var easViewModel: EASCommandViewModel
    @StateObject private var pathManager = LocalDataManager()
    
    init(projectPath: Binding<URL?>, profiles: Binding<[Profile]>) {
        self._projectPath = projectPath
        self._profiles = profiles
        let path = projectPath.wrappedValue?.path ?? ""
        self._easViewModel = StateObject(wrappedValue: EASCommandViewModel(projectPath: path, pathManager: LocalDataManager()))
    }
    
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading) {
                List(profiles, selection: $selectedProfile) { profile in
                    NavigationLink(value: profile) {
                        Text(profile.name)
                    }
                }
            }
        } detail: {
            if let profile = selectedProfile {
                HStack {
                    VStack(alignment: .leading) {
                        ProfileDetailsView(profile: profile)
                        ProfilesActionsView(easViewModel: easViewModel, profileName: profile.name)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                Text("Select a profile to view details")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            if selectedProfile == nil, let firstProfile = profiles.first {
                selectedProfile = firstProfile
            }
        }
    }
}

#Preview {
    @Previewable @State var profiles: [Profile] = [Profile(name: "development", developmentBuild: true, channel: "development", distribution: .internal)]
    @Previewable @State var projectPath: URL? = URL(filePath: "/Users/henry/Projects/routinify")

    ProjectView(projectPath: $projectPath, profiles: $profiles)
}
