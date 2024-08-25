//
//  EAS.swift
//  EASManager
//
//  Created by Henry on 8/25/24.
//

import Foundation
import SwiftUI

class EAS: ObservableObject {
    @Published var profiles: [Profile] = [Profile]()
    @State private var errorMessage: String?
    
    @Published var projectPath: String = ""
    @Published var cliPath: String = ""
    @Published var output: String = ""
    @Published var error: String?
    @Published var isLoading: Bool = false
    
    init() {
        projectPath = UserDefaults.standard.string(forKey: "lastOpenedProjectPath") ?? ""
        cliPath = UserDefaults.standard.string(forKey: "cliPath") ?? ""
        readEASJson()
    }
    
    func buildIos(profile: String) {
        runCommand(["build", "--profile", profile,  "--platform", "ios", "--non-interactive", "--no-wait"])
    }
    
    func buildAndroid(profile: String) {
        runCommand(["build", "--profile", profile,  "--platform", "android", "--non-interactive", "--no-wait"])
    }
    
    func buildAll(profile: String) {
        runCommand(["build", "--profile", profile,  "--platform", "all", "--non-interactive", "--no-wait"])
    }
    
    private func runCommand(_ arguments: [String]) {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let result = CLIUtils.runEASCommand(arguments)
            
            DispatchQueue.main.async {
                self.output = result.output ?? ""
                self.error = result.error
                if self.error == nil && self.output.isEmpty {
                    self.error = "Command executed but produced no output. Please check if the EAS CLI path is correct."
                }
                self.isLoading = false
            }
        }
    }
    
    func addProfile(_ profile: Profile) {
        profiles.append(profile)
    }

    func readEASJson() {
        let url = URL(fileURLWithPath: projectPath)
        let easJsonURL = url.appendingPathComponent("eas.json")
        
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
//                errorMessage = nil
            } else {
//                errorMessage = "Failed to find 'build' key or it's not in the expected format"
            }
        } catch {
//            errorMessage = "Error reading or parsing eas.json: \(error.localizedDescription)"
        }
    }
}
