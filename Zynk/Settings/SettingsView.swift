//
//  SwiftUIView.swift
//  Zynk
//
//  Created by Henry on 8/30/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var eas: EAS

    var body: some View {
        VStack(alignment: .leading) {
            Text("Settings")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 16)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("EAS CLI path:")
                    .fontWeight(.medium)
                HStack(alignment: .center, spacing: 16) {
                    Text(eas.cliPath.trimmingCharacters(in: .whitespacesAndNewlines))
                    Button("Change") {
                        print("changing path")
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    @Previewable @StateObject var eas = EAS()
    SettingsView()
        .environmentObject(eas)
}
