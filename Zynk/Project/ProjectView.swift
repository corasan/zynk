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
                        Spacer()
                        SecretsTable(profile: Binding(
                            get: { profile.name },
                            set: { newValue in }
                        ))
                    }
                    Spacer()
                }
            } else {
                Text("Select a profile to view details")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(selectedProfile?.name.capitalized ?? "")
        .toolbar {
            ToolbarItemGroup(placement: .confirmationAction) {
                Menu {
                    Button("Build iOS", action: { build(.ios) })
                    Button("Build Android", action: {  build(.android) })
                    Button("Build all", action: { build() })
                } label: {
                    Button(action: {}) {
                        Label("Build", systemImage: "hammer")
                            .labelStyle(.iconOnly)
                    }
                }
                Menu {
                    Button("Update iOS", action: { update(.ios) })
                    Button("Update Android", action: { update(.android)})
                    Button("Update all", action: { update() })
                } label: {
                    Button(action: {
                        
                    }) {
                        HStack {
                            Label("Update", systemImage: "icloud.and.arrow.up")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
            }
        }
        .onAppear {
            if selectedProfile == nil, let firstProfile = eas.profiles.first {
                selectedProfile = firstProfile
            }
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
}

#Preview {
    @Previewable @State var eas = EAS()
    ProjectView()
        .environmentObject(eas)
}
