//
//  CLIUtils.swift
//  EASManager
//
//  Created by Henry on 8/25/24.
//

import Foundation
import SwiftUI

class CLIUtils {
    private static var cliPath: String {
        UserDefaults.standard.string(forKey: "cliPath") ?? ""
    }
    
    private static var projectPath: String {
        UserDefaults.standard.string(forKey: "lastOpenedProjectPath") ?? ""
    }
    
    init() {
        getEASCLIPath()
    }
    
    static func runEASCommand(_ arguments: [String]) -> (output: String?, error: String?) {
        guard !cliPath.isEmpty else {
            print("Error: EAS CLI path is not set.")
            return (nil, "EAS CLI path is not set. Please set the path in the settings.")
        }

        print("--- Starting EAS Command Execution ---")
        print("CLI Path: \(cliPath)")
        print("Project Path: \(projectPath)")
        print("Arguments: \(arguments)")
        
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        // Use source to load bash profile, which should set up Node.js environment
        let command = """
            source ~/.zshrc
            which node
            which npm
            which eas
            eas \(arguments.joined(separator: " "))
        """
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-c", command]
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("Failed to run EAS command: \(error.localizedDescription)")
            return (nil, "Failed to run EAS command: \(error.localizedDescription)")
        }
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let error = String(data: errorData, encoding: .utf8) ?? ""
        
        print(output)
        
        print("--- EAS Command Execution Completed ---")
        
        return (output.isEmpty ? nil : output, error.isEmpty ? nil : error)
    }
    
    private func getEASCLIPath() {
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        let command = """
            source ~/.zshrc
            which eas
        """
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-c", command]
        task.standardOutput = outputPipe
        task.standardError = errorPipe

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("Failed to get EAS path: \(error.localizedDescription)")
            return
        }
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorStr = String(data: errorData, encoding: .utf8) ?? ""
        print("Error: \(errorStr)")
        
        UserDefaults.standard.set(output, forKey: "cliPath")
    }
}
