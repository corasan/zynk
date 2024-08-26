//
//  ProjectDetailsView.swift
//  EASManager
//
//  Created by Henry on 8/24/24.
//

import SwiftUI

struct ProfileDetailsView: View {
    var profile: Profile
    @EnvironmentObject var eas: EAS

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                VStack {
                    Text(profile.name.capitalized)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }
                Text("Project Name: \(eas.projectName)")
                Text("Updates channel: \(profile.channel.lowercased())")
                Text("Distribution: \(profile.distribution.description.lowercased())")
                Text("Development build: \(profile.developmentBuild ? "Yes" : "No")")
            }
            Spacer()
            if eas.isBuildLoading {
                HStack {
                    Text("Starting build in EAS Server...")
                    Image(systemName: "progress.indicator")
                        .symbolEffect(.variableColor.iterative.hideInactiveLayers.nonReversing)
                }
            }
            if eas.isUpdateLoading {
                HStack {
                    Text("Creating OTA Update for branch: \(profile.channel)")
                    Image(systemName: "progress.indicator")
                        .symbolEffect(.variableColor.iterative.hideInactiveLayers.nonReversing)
                }
            }
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var eas = EAS()
    @Previewable var profile = Profile(name: "Test Project", developmentBuild: true, channel: "Staging", distribution: .internal)
    ProfileDetailsView(profile: profile)
        .environmentObject(eas)
}
