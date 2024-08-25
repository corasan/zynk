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
    
    static func runEASCommand(_ arguments: [String]) -> (output: String?, error: String?) {
        print("--- Starting EAS Command Execution ---")
        print("CLI Path: \(cliPath)")
        print("Project Path: \(projectPath)")
        print("Arguments: \(arguments)")
        
        guard !cliPath.isEmpty else {
            print("Error: EAS CLI path is not set.")
            return (nil, "EAS CLI path is not set. Please set the path in the settings.")
        }
        
        print("Checking if CLI path exists...")
        guard FileManager.default.fileExists(atPath: cliPath) else {
            print("Error: EAS CLI not found at specified path: \(cliPath)")
            return (nil, "EAS CLI not found at specified path. Please check the path and try again.")
        }
        
        print("Checking if project path exists...")
        guard FileManager.default.fileExists(atPath: projectPath) else {
            print("Error: Project directory not found: \(projectPath)")
            return (nil, "Project directory not found. Please check the project path.")
        }
        
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
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
            print("Command started successfully")
            
            print("Waiting for command to complete...")
            task.waitUntilExit()
            print("Command completed with exit status: \(task.terminationStatus)")
        } catch {
            print("Failed to run EAS command: \(error.localizedDescription)")
            return (nil, "Failed to run EAS command: \(error.localizedDescription)")
        }
        
        print("Reading command output...")
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let error = String(data: errorData, encoding: .utf8) ?? ""
        
        print(output)
        
        print("--- EAS Command Execution Completed ---")
        
        return (output.isEmpty ? nil : output, error.isEmpty ? nil : error)
    }
}
