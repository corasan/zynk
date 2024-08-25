//
//  ProfilesActionsView.swift
//  EASManager
//
//  Created by Henry on 8/24/24.
//

import SwiftUI

struct ProfilesActionsView: View {
    var body: some View {
        VStack {
            HStack {
                Label("Build", systemImage: "hammer.fill")
                    .foregroundStyle(.blue)
                    .fontWeight(.medium)
//                Button("Build", systemImage: "hammer.fill", action: build)
//                    .labelStyle(.iconOnly)
//                    .foregroundStyle(.blue)
//                    .buttonStyle(.plain)
                
//                Button("Update", systemImage: "square.2.layers.3d.top.filled", action: update)
//                    .labelStyle(.iconOnly)
//                    .foregroundStyle(.blue)
//                    .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
    }
    
    func build() {
        print("Building")
    }
}

#Preview {
    ProfilesActionsView()
}
