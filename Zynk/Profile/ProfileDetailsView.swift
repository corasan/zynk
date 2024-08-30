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
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 6) {
                    Text(profile.name.capitalized)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 4)
                    Badge(
                        text: profile.distribution.description,
                        icon: profile.distribution == .store ? "storefront.fill" : "lock.fill",
                        badgeType: profile.distribution == .store ? .store : .internal
                    )

                    if profile.developmentClient {
                        Badge(text: "development", icon: "bolt.fill", badgeType: .development)
                    }
                }
                Text("Updates channel: \(profile.channel.isEmpty ? profile.name : profile.channel)")
                    .padding(.horizontal, 4)
            }
            Spacer()
            VStack(alignment: .trailing) {
                if eas.isBuildLoading {
                    HStack {
                        Text("Starting build")
                        Image(systemName: "progress.indicator")
                            .symbolEffect(.variableColor.iterative.hideInactiveLayers.nonReversing)
                    }
                }
                if eas.isUpdateLoading {
                    HStack {
                        Text("OTA Update for: \(profile.channel)")
                        Image(systemName: "progress.indicator")
                            .symbolEffect(.variableColor.iterative.hideInactiveLayers.nonReversing)
                    }
                }
            }
        }
        .padding(16)
    }
}

#Preview {
    @Previewable @State var eas = EAS()
    @Previewable var profile = Profile(name: "Test Project", developmentClient: true, channel: "Staging", distribution: .internal)
    ProfileDetailsView(profile: profile)
        .environmentObject(eas)
}
