//
//  ProjectView.swift
//  EASManager
//
//  Created by Henry on 8/24/24.
//

import SwiftUI

struct ProjectView: View {
    @EnvironmentObject var eas: EAS
    @State var selectedProfile: Profile?
    @AppStorage("lastOpenedProjectPath") var lastOpenedProjectPath: String = ""
    
    
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading) {
                List(eas.profiles, selection: $selectedProfile) { profile in
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
                        ProfilesActionsView(profileName: profile.name)
                        Spacer()
                        SecretsTable()
                    }
                    Spacer()
                }
            } else {
                Text("Select a profile to view details")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            if selectedProfile == nil, let firstProfile = eas.profiles.first {
                selectedProfile = firstProfile
            }
        }
    }
}

#Preview {
    @Previewable @State var eas = EAS()

    ProjectView()
        .environmentObject(eas)

}
