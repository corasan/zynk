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
            RoundedRectangle(cornerRadius: 0)
                .fill(isActive ? .blue.opacity(0.05) : .gray.opacity(0))
                .animation(.easeIn(duration: 0.2), value: isActive)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(isActive ? Color.blue : Color.gray, lineWidth: isActive ? 2 : 0)
                        .animation(.easeInOut(duration: 0.2), value: isActive)
                        
                )
                .zIndex(isActive ? 1 : 10)
            content
        }
        .padding(1)
        .frame(minHeight: 200)
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
            envsManager.parseEnvFile(contents: contents)
        } catch {
            print("Error reading file: \(error.localizedDescription)")
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
