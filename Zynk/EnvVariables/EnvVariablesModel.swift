//
//  SecretsManager.swift
//  EASManager
//
//  Created by Henry on 8/25/24.
//

import Foundation
import SwiftUI

struct Variable: Identifiable, Equatable {
    let id = UUID()
    var variable: String
    var value: String
}

class EnvVariablesModel: ObservableObject {
    var projectName: String {
        UserDefaults.standard.string(forKey: "lastOpenedProjectName") ?? ""
    }
    @Published var variables: [Variable] = []
    @Published var profileName: String = "" {
        didSet {
            loadFromFile()
        }
    }
    @Published var didUpload: Bool = false
    
    func addItem(key: String, value: String) {
        variables.append(Variable(variable: key, value: value))
        writeToFile()
    }
    
    func editItem(at index: Int, key: String, value: String) {
        if !variables.isEmpty {
            variables[index].variable = key
            variables[index].value = value
            writeToFile()
        }
    }
    
    func removeItem(id: UUID) {
        if !variables.isEmpty {
            if let index = variables.firstIndex(where: { $0.id == id }) {
                variables.remove(atOffsets: IndexSet(integer: index))
                writeToFile()
            }
        }
    }
    
    func removeSelectedItems(items: Set<Variable.ID>) {
        if !variables.isEmpty {
            for item in items {
                removeItem(id: item.self)
            }
        }
    }
    
    func reload() {
        loadFromFile()
    }
    
    func parseEnvFile(contents: String) {
        var envs: [(key: String, value: String)] = []
        let lines = contents.components(separatedBy: .newlines)
        for line in lines {
            let components = line.split(separator: "=", maxSplits: 1)
            guard components.count == 2 else { continue }
            let key = String(components[0])
            let value = String(components[1])
            envs.append((key: key, value: value))
        }
        
        guard let zynkDirectory = getProjectDirectory() else {
            print("Error: Could not get source directory")
            return
        }
        let fileName = ".env.\(profileName)"
        let fileContent = envs.map { "\($0.key)=\($0.value)" }.joined(separator: "\n")
        let fileURL = zynkDirectory.appendingPathComponent(fileName)
        do {
            try FileManager.default.createDirectory(at: zynkDirectory, withIntermediateDirectories: true, attributes: nil)
            try fileContent.write(to: fileURL, atomically: true, encoding: .utf8)
            didUpload = true
        } catch {
            print("Error writing file: \(error.localizedDescription)")
        }
    }
    
    private func loadFromFile() {
        guard let appDirectory = getProjectDirectory() else { return }
        
        let fileName = ".env.\(profileName)"
        let fileURL = appDirectory.appendingPathComponent(fileName)
                
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            let newVariables = lines.compactMap { line -> Variable? in
                let parts = line.components(separatedBy: "=")
                guard parts.count == 2 else {
                    return nil
                }
                
                let variable = parts[0].trimmingCharacters(in: .whitespaces)
                var value = parts[1].trimmingCharacters(in: .whitespaces)
                
                if value.first == "\"" && value.last == "\"" {
                    value = String(value.dropFirst().dropLast())
                }
                
                return Variable(variable: variable, value: value)
            }

            DispatchQueue.main.async {
                self.variables = newVariables
                self.copyEnvFile()
            }
        } catch {
            print("Error reading .env.* file: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.variables = []
            }
        }
    }
    
    private func copyEnvFile() {
        guard let sourceDirectory = getProjectDirectory() else {
            return
        }
        
        let sourceFileName = ".env.\(profileName)"
        let sourceURL = sourceDirectory.appendingPathComponent(sourceFileName)
        
        guard let destinationPath = UserDefaults.standard.string(forKey: "lastOpenedProjectPath") else {
            return
        }
        
        let destinationURL = URL(fileURLWithPath: destinationPath).appendingPathComponent(".env.local")

        // Read the contents of the source file
        guard let sourceData = FileManager.default.contents(atPath: sourceURL.path) else {
            return
        }
                
        do {
            // Write the contents to the destination file
            try sourceData.write(to: destinationURL, options: .atomic)
        } catch {
        }
    }
    
    func copyLocalEnvToZynkDir() {
        guard let zynkPath = getProjectDirectory() else {
            return
        }
        let destinationURL = zynkPath.appendingPathComponent(".env.\(profileName)")
        
        guard let sourceAppDirectory = UserDefaults.standard.string(forKey: "lastOpenedProjectPath") else {
            return
        }
        
        let sourceURL = URL(fileURLWithPath: sourceAppDirectory).appendingPathComponent(".env.local")
        
        guard let sourceData = FileManager.default.contents(atPath: sourceURL.path) else {
            print("Error: Unable to read .env.local file from \(sourceURL.path)")
            return
        }
        
        do {
            try sourceData.write(to: destinationURL, options: .atomic)
            reload()
        } catch {
            print("Could not write .env.local file to \(destinationURL.path). Error: \(error.localizedDescription)")
        }
    }
    
    private func writeToFile() {
        guard let appDirectory = getProjectDirectory() else {
            print("Error: Unable to get project directory")
            return
        }
        
        let fileName = ".env.\(profileName)"
        let fileContent = variables.map { "\($0.variable)=\"\($0.value)\"" }.joined(separator: "\n")
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
