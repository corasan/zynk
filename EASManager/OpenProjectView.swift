//
//  OpenProjectView.swift
//  EASManager
//
//  Created by Henry on 8/24/24.
//

import SwiftUI

struct OpenProjectView: View {
    @Binding var isProjectSelected: Bool
    @Binding var profiles: [Profile]
    @Binding var projectPath: URL?

    @State private var errorMessage: String?
    @State private var isShowingPicker = false

    var body: some View {
        VStack {
            Text("Select a project")
                .font(.largeTitle)
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
                        projectPath = folder
                        readEASJson(in: folder)
                        isProjectSelected = true
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
    
    func readEASJson(in folder: URL) {
        let easJsonURL = folder.appendingPathComponent("eas.json")
        
        do {
            let data = try Data(contentsOf: easJsonURL)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = json as? [String: Any],
               let build = dictionary["build"] as? [String: [String: Any]] {
                profiles = build.compactMap { (name, config) -> Profile? in
                    guard let channel = config["channel"] as? String,
                          let distributionString = config["distribution"] as? String,
                          let distribution = DistributionType(rawValue: distributionString) else {
                        return nil
                    }
                    
                    let developmentBuild = config["developmentBuild"] as? Bool ?? false
                    
                    return Profile(name: name,
                                   developmentBuild: developmentBuild,
                                   channel: channel,
                                   distribution: distribution)
                }
                errorMessage = nil
            } else {
                errorMessage = "Failed to find 'build' key or it's not in the expected format"
            }
        } catch {
            errorMessage = "Error reading or parsing eas.json: \(error.localizedDescription)"
        }
    }
}

#Preview {
    @Previewable @State var isProjectSelected = false
    @Previewable @State var profiles: [Profile] = [Profile(name: "development", developmentBuild: true, channel: "development", distribution: .internal)]
    @Previewable @State var projectPath: URL? = URL(filePath: "/Users/henry/Projects/routinify")

    OpenProjectView(isProjectSelected: $isProjectSelected, profiles: $profiles, projectPath: $projectPath)
}
