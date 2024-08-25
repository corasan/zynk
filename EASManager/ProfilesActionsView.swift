//
//  ProfilesActionsView.swift
//  EASManager
//
//  Created by Henry on 8/24/24.
//

import SwiftUI

struct ProfilesActionsView: View {
    @EnvironmentObject var eas: EAS
    var profileName: String

    var body: some View {
        VStack {
            HStack {
                Button(action: buildIos) {
                    Label("Build", systemImage: "hammer.fill")
                        .foregroundStyle(.blue)
                        .fontWeight(.medium)
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
    }
    
    func buildIos() {
        eas.buildIos(profile: profileName)
    }
}

#Preview {
    @Previewable @StateObject var eas = EAS()
    ProfilesActionsView(profileName: "development")
        .environmentObject(eas)
}
