//
//  OpenProjectView.swift
//  EASManager
//
//  Created by Henry on 8/24/24.
//

import SwiftUI

struct OpenProjectView: View {
    @EnvironmentObject var eas: EAS
    @State private var errorMessage: String?
    @State private var isShowingPicker = false
    @AppStorage("cliPath") private var cliPath: String = ""
    @AppStorage("lastOpenedProjectPath") private var lastOpenedProjectPath: String = ""

    var body: some View {
        VStack {
            Text("Select a project")
                .font(.largeTitle)
            Text("EAS CLI Path: \(cliPath)")
                .padding(.bottom)
            if cliPath.isEmpty {
                HStack {
                    TextField("EAS CLI Path", text: $cliPath)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
            } else {
                Button("Open project") {
                    isShowingPicker = true
                }
                .fileImporter(
                    isPresented: $isShowingPicker,
                    allowedContentTypes: [.directory],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let folders):
                        if let folder = folders.first {
                            eas.saveSecurityScopedBookmark(for: folder)
                            eas.projectPath = folder.path
                            lastOpenedProjectPath = folder.path
                            eas.readEASJson()
                            eas.readAppJson()
                        }
                    case .failure(let error):
                        errorMessage = "Error selecting folder: \(error.localizedDescription)"
                    }
                }
            }
            
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                Button(action: {
                    UserDefaults.standard.removePersistentDomain(forName: "com.henrypl.zynk")
                }) {
                    Label("Clear", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var eas = EAS()
    OpenProjectView()
        .environmentObject(eas)
}
