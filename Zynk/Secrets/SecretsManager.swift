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
        copyEnvFile()
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
            }
        } catch {
//            print("Error reading file: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.secrets = []
//                print("Cleared secrets array due to error")
            }
        }
    }
    
    private func copyEnvFile() {
        guard let sourceDirectory = getProjectDirectory() else {
//            print("Error: Could not get source directory")
            return
        }
        
        let sourceFileName = ".env.\(profileName)"
        let sourceURL = sourceDirectory.appendingPathComponent(sourceFileName)
        
        guard let destinationPath = UserDefaults.standard.string(forKey: "lastOpenedProjectPath") else {
//            print("Error: No project path found in UserDefaults")
            return
        }
        
        let destinationURL = URL(fileURLWithPath: destinationPath).appendingPathComponent(".env.local")

        // Read the contents of the source file
        guard let sourceData = FileManager.default.contents(atPath: sourceURL.path) else {
//            print("Error: Could not read source file at \(sourceURL.path)")
            return
        }
                
        do {
            // Write the contents to the destination file
            try sourceData.write(to: destinationURL, options: .atomic)
//            print("File successfully copied to \(destinationURL.path)")
        } catch {
//            print("Error writing file: \(error.localizedDescription)")
        }
    }
    
    private func writeToFile() {
        guard let appDirectory = getProjectDirectory() else {
            print("Error: Unable to get project directory")
            return
        }
        
        let fileName = ".env.\(profileName)"
        let fileContent = secrets.map { "\($0.variable)=\"\($0.value)\"" }.joined(separator: "\n")
        let fileURL = appDirectory.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
            try fileContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("File written successfully to \(fileURL.path)")
        } catch {
            print("Error writing file: \(error.localizedDescription)")
        }
    }
    
    private func getProjectDirectory() -> URL? {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let zynkDirectory = homeDirectory.appendingPathComponent(".zynk", isDirectory: true)
        let projectDirectory = zynkDirectory.appendingPathComponent(projectName, isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: zynkDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: zynkDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating .zynk directory: \(error.localizedDescription)")
                return nil
            }
        }
        return projectDirectory
    }
}
