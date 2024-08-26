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
                Text("Updates channel: \(profile.channel)")
                Text("Distribution: \(profile.distribution.description)")
                Text("Development Build: \(profile.developmentBuild ? "Yes" : "No")")
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable var profile = Profile(name: "Test Project", developmentBuild: true, channel: "Staging", distribution: .internal)

    ProfileDetailsView(profile: profile)
}
