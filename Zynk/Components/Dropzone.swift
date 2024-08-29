//
//  Dropzone.swift
//  Zynk
//
//  Created by Henry on 8/29/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct Dropzone<Content: View>: View {
    let content: Content
    @State private var isActive = false
    @EnvironmentObject var envsManager: EnvVariablesModel
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.windowBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isActive ? Color.blue : Color.gray, lineWidth: isActive ? 2 : 0)
                        .animation(.easeInOut, value: isActive)
                )
            content
        }
        .frame(minHeight: 200)
        .padding()
        .onDrop(of: [UTType.fileURL], isTargeted: $isActive) { providers -> Bool in
            guard let provider = providers.first else { return false }
            
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { urlData, error in
                DispatchQueue.main.async {
                    if let urlData = urlData as? Data,
                       let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                        loadEnvFile(from: url)
                    }
                }
            }
            return true
        }
    }
    
    private func loadEnvFile(from url: URL) {
        guard url.absoluteString.contains(".env") else {
            print("Not an .env file")
            return
        }
        
        do {
            let contents = try String(contentsOf: url, encoding: .utf8)
            parseEnvFile(contents: contents)
        } catch {
            print("Error reading file: \(error.localizedDescription)")
        }
    }
    
    private func parseEnvFile(contents: String) {
        var envs: [(key: String, value: String)] = []
        let lines = contents.components(separatedBy: .newlines)
        for line in lines {
            let components = line.split(separator: "=", maxSplits: 1)
            guard components.count == 2 else { continue }
            let key = String(components[0])
            let value = String(components[1])
            envs.append((key: key, value: value))
        }
        
        guard let zynkDirectory = envsManager.getProjectDirectory() else {
            print("Error: Could not get source directory")
            return
        }
        let fileName = ".env.\(envsManager.profileName)"
        let fileContent = envs.map { "\($0.key)=\($0.value)" }.joined(separator: "\n")
        let fileURL = zynkDirectory.appendingPathComponent(fileName)
        do {
            try FileManager.default.createDirectory(at: zynkDirectory, withIntermediateDirectories: true, attributes: nil)
            try fileContent.write(to: fileURL, atomically: true, encoding: .utf8)
            envsManager.didUpload = true
        } catch {
            print("Error writing file: \(error.localizedDescription)")
        }
    }
}

struct DropzoneExample: View {
    var body: some View {
        VStack {
            Dropzone {
                Text("Dropzone Content")
                    .font(.headline)
                    .padding()
            }
        }
    }
}

#Preview {
    DropzoneExample()
}
