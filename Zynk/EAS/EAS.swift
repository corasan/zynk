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
    
    @Published var output: String = ""
    @Published var error: String?
    @Published var isLoading: Bool = false
    @Published var isUpdateLoading: Bool = false
    @Published var isBuildLoading: Bool = false
    
    @AppStorage("lastOpenedProjectPath") var projectPath: String = ""
    @AppStorage("cliPath") var cliPath: String = ""
    @AppStorage("lastOpenedProjectName") var projectName: String = ""
    @AppStorage("lastOpenedProfileName") var lastOpenedProfileName = ""
    
    
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

    func readEASJson() {
        let url = URL(fileURLWithPath: projectPath)
        let easJsonURL = url.appendingPathComponent("eas.json")
        
        do {
            let data = try Data(contentsOf: easJsonURL)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = json as? [String: Any],
               let build = dictionary["build"] as? [String: [String: Any]] {
                profiles = build.compactMap { (name, config) -> Profile? in
                    let channel = config["channel"] as? String ?? ""
                    let distributionString = config["distribution"] as? String ?? ""
                    let distribution = DistributionType(rawValue: distributionString) ?? .internal
                    let developmentClient = config["developmentClient"] as? Bool ?? false
                    
                    return Profile(name: name,
                                   developmentClient: developmentClient,
                                   channel: channel,
                                   distribution: distribution)
                }
                print("Open project profiles: \(profiles.map { $0.name })")
                lastOpenedProfileName = profiles.first?.name ?? ""
                errorMessage = nil
            } else {
                errorMessage = "Failed to find 'build' key or it's not in the expected format"
            }
        } catch {
            errorMessage = "Error reading or parsing eas.json: \(error.localizedDescription)"
        }
    }
    
    func readAppJson() {
        let url = URL(fileURLWithPath: projectPath)
        let appJsonURL = url.appendingPathComponent("app.json")
        
        do {
            let data = try Data(contentsOf: appJsonURL)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if let dictionary = json as? [String: Any] {
                if let expo = dictionary["expo"] as? [String: Any] {
                    if let name = expo["name"] as? String {
                        UserDefaults.standard.set(name, forKey: "lastOpenedProjectName")
                    }
                }
            }
        } catch {
            print("Error reading app.json: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    func saveSecurityScopedBookmark(for url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            errorMessage = "Error accessing security scoped resource"
            print(errorMessage ?? "")
            return
        }
        do {
            let bookmark = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmark, forKey: "projectFolderBookmark")
        } catch {
            print("Error saving bookmark: \(error.localizedDescription)")
        }
    }
    
    func loadSecurityScopedBookmark() {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "projectFolderBookmark") else { return }
        
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            
            if isStale {
                // Bookmark is stale, you might want to ask the user to select the folder again
                errorMessage = "The saved project location is no longer accessible. Please select the project folder again."
                return
            }
            
            if url.startAccessingSecurityScopedResource() {
                projectPath = url.path
                readEASJson()
                readAppJson()
                url.stopAccessingSecurityScopedResource()
            } else {
                errorMessage = "Failed to access the project folder. Please select it again."
            }
        } catch {
            errorMessage = "Error accessing project folder: \(error.localizedDescription)"
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
