//
//  ProfilesActionsView.swift
//  EASManager
//
//  Created by Henry on 8/24/24.
//

import SwiftUI

struct ProfilesActionsView: View {
    @ObservedObject var easViewModel: EASCommandViewModel
    var profileName: String

    var body: some View {
        VStack {
            HStack {
                Button(action: build) {
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
    
    func build() {
        print("Building")
        easViewModel.runCommand(["build", "--profile", profileName,  "--platform", "ios", "--non-interactive", "--no-wait"])
    }
}

//#Preview {
//    let projectPath = "/Users/henry/Projects/routinify"
//    let easViewModel = EASCommandViewModel(projectPath: projectPath)
//    ProfilesActionsView(easViewModel: easViewModel, profileName: "development")
//}
