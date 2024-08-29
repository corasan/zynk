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
                    HStack {
                        Image(systemName: profile.distribution == .store ? "storefront.fill" : "lock.fill")
                            .font(.footnote)
                        Text(profile.distribution.description)
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(profile.distribution == .store ? Color.blue.opacity(0.2) : Color.purple.opacity(0.2))
                    .clipShape(Capsule())

                    if profile.developmentClient {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .font(.footnote)
                            Text("development")
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .clipShape(Capsule())
                    }
                }
                Text("Updates channel: \(profile.channel.lowercased())")
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
