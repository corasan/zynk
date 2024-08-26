//
//  SecretsManager.swift
//  EASManager
//
//  Created by Henry on 8/25/24.
//

import Foundation

struct Secret: Identifiable {
    let id = UUID()
    var variable: String
    var value: String
}

class SecretsManager: ObservableObject {
    @Published var secrets: [Secret] = []
    @Published var profileName: String {
        didSet {
            loadFromFile()
        }
    }
    var projectName: String {
        UserDefaults.standard.string(forKey: "lastOpenedProjectName") ?? ""
    }
        
    init (profile: String) {
        profileName = profile
        loadFromFile()
    }
    
    func addItem(key: String, value: String) {
        secrets.append(Secret(variable: key, value: value))
        writeToFile()
    }
    
    func removeItem(at offsets: IndexSet) {
        if !secrets.isEmpty {
            secrets.remove(atOffsets: offsets)
            writeToFile()
        }
    }
    
    private func loadFromFile() {
        guard let appDirectory = getProjectDirectory() else { return }
        
        let fileName = ".env.\(profileName)"
        let fileURL = appDirectory.appendingPathComponent(fileName)
        
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            let newSecrets = lines.compactMap { line -> Secret? in
                let parts = line.components(separatedBy: "=")
                guard parts.count == 2 else {
                    print("Skipping invalid line: \(line)")
                    return nil
                }
                
                let variable = parts[0].trimmingCharacters(in: .whitespaces)
                var value = parts[1].trimmingCharacters(in: .whitespaces)
                
                if value.first == "\"" && value.last == "\"" {
                    value = String(value.dropFirst().dropLast())
                }
                
                return Secret(variable: variable, value: value)
            }
            
            DispatchQueue.main.async {
                self.secrets = newSecrets
                print("Updated secrets array. Count: \(self.secrets.count)")
            }
        } catch {
            print("Error reading file: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.secrets = []
                print("Cleared secrets array due to error")
            }
        }
    }
    
    private func writeToFile() {
        guard let appDirectory = getProjectDirectory() else { return }
        
        let fileName = ".env.\(profileName)"
        let fileContent = secrets.map { "\($0.variable)=\"\($0.value)\"" }.joined(separator: "\n")
        let fileURL = appDirectory.appendingPathComponent(fileName)
        
        do {
            try fileContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("File written successfully to \(fileURL.path)")
        } catch {
            print("Error writing file: \(error.localizedDescription)")
        }
    }
    
    private func getProjectDirectory() -> URL? {
        guard let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("Error: Unable to find application support directory")
            return nil
        }
        
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.henrypl.eas-manager"
        let appDirectory = appSupportDirectory.appendingPathComponent(bundleIdentifier, isDirectory: true)
        let projectDirectory = appDirectory.appendingPathComponent(projectName, isDirectory: true)
        
        // Create the directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: appDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating app directory: \(error.localizedDescription)")
                return nil
            }
        }
        
        return projectDirectory
    }
}
