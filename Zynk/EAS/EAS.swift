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
    @Published var projectName: String = ""
    @Published var isUpdateLoading: Bool = false
    @Published var isBuildLoading: Bool = false
    
    init() {
        projectPath = UserDefaults.standard.string(forKey: "lastOpenedProjectPath") ?? ""
        cliPath = UserDefaults.standard.string(forKey: "cliPath") ?? ""
        projectName = UserDefaults.standard.string(forKey: "lastOpenedProjectName") ?? ""
        readEASJson()
        readAppJson()
    }
    
    func build(profile: String, platform: EASPlatform = .all) {
        isBuildLoading = true
        runCommand(["build", "--profile", profile,  "--platform", platform.description, "--non-interactive", "--no-wait"]) { loading in
            self.isBuildLoading = loading
        }
    }
    
    func update(profile: String, platform: EASPlatform = .all) {
        isUpdateLoading = true
        runCommand(["update", "--branch", profile,  "--platform", platform.description, "--auto"]) { loading in
            self.isUpdateLoading = loading
        }
    }
    
    private func runCommand(_ arguments: [String], completion: @escaping (Bool) -> Void) {
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
                completion(self.isLoading)
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
    
    func readAppJson() {
        let url = URL(fileURLWithPath: projectPath)
        let appJsonURL = url.appendingPathComponent("app.json")
        print(appJsonURL)
        
        do {
            let data = try Data(contentsOf: appJsonURL)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = json as? [String: Any] {
//                print("in here, dictionary is not nil")
                if let expo = dictionary["expo"] as? [String: Any] {
//                    print("in here, expo is not nil")
                    if let name = expo["name"] as? String {
                        UserDefaults.standard.set(name, forKey: "lastOpenedProjectName")
                    }
                }
            }
        } catch {
//            print("Error reading app.json: \(error.localizedDescription)")
        }
    }
}

enum EASPlatform: String, CustomStringConvertible {
    case ios = "ios"
    case android = "android"
    case all = "all"
    
    var description: String {
        switch self {
        case .ios:
            return "ios"
        case .android:
            return "android"
        case .all:
            return "all"
        }
    }
    
    init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "ios":
            self = .ios
        case "android":
            self = .android
        case "all":
            self = .all
        default:
            return nil
        }
    }
}
