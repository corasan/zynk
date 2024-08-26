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
//    @AppStorage("lastOpenedProjectName") private var lastOpenedProjectName: String = ""

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
            }
            Button("Open project") {
                isShowingPicker = true
            }
            .fileImporter(
                isPresented: $isShowingPicker,
                allowedContentTypes: [.folder],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let folders):
                    if let folder = folders.first {
                        eas.projectPath = folder.path
                        lastOpenedProjectPath = folder.path
                        eas.readEASJson()
                    }
                case .failure(let error):
                    errorMessage = "Error selecting folder: \(error.localizedDescription)"
                }
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
    
//    func readEASJson(in folder: URL) {
//        let easJsonURL = folder.appendingPathComponent("eas.json")
//        
//        do {
//            let data = try Data(contentsOf: easJsonURL)
//            let json = try JSONSerialization.jsonObject(with: data, options: [])
//            
//            if let dictionary = json as? [String: Any],
//               let build = dictionary["build"] as? [String: [String: Any]] {
//                profiles = build.compactMap { (name, config) -> Profile? in
//                    guard let channel = config["channel"] as? String,
//                          let distributionString = config["distribution"] as? String,
//                          let distribution = DistributionType(rawValue: distributionString) else {
//                        return nil
//                    }
//                    
//                    let developmentBuild = config["developmentBuild"] as? Bool ?? false
//                    
//                    return Profile(name: name,
//                                   developmentBuild: developmentBuild,
//                                   channel: channel,
//                                   distribution: distribution)
//                }
//                errorMessage = nil
//            } else {
//                errorMessage = "Failed to find 'build' key or it's not in the expected format"
//            }
//        } catch {
//            errorMessage = "Error reading or parsing eas.json: \(error.localizedDescription)"
//        }
//    }
}

#Preview {
    @Previewable @State var eas = EAS()
    OpenProjectView()
        .environmentObject(eas)
}
