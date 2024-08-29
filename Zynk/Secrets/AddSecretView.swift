//
//  AddSecret.swift
//  EASManager
//
//  Created by Henry on 8/25/24.
//

import SwiftUI

struct AddSecretButton: View {
    @State private var isPresented = false

    var body: some View {
        Button(action: {
            isPresented.toggle()
        }) {
            Label("Add", systemImage: "plus")
                .foregroundStyle(.foreground)
                .fontWeight(.medium)
                .labelStyle(.iconOnly)
        }
        .sheet(isPresented: $isPresented) {
            AddSecretView(isPresented: $isPresented)
        }
    }
}

struct NewSecret: Identifiable, Equatable {
    let id: UUID
    let variable: String
    let value: String
}

class SecretsViewModel: ObservableObject {
    @Published var secrets: [NewSecret] = []
    
    init() {
        // Initialize with some sample data
        secrets = [
            NewSecret(id: UUID(), variable: "", value: ""),
        ]
    }
    
    func updateSecret(id: UUID, variable: String, value: String) {
        if let index = secrets.firstIndex(where: { $0.id == id }) {
            secrets[index] = NewSecret(id: id, variable: variable, value: value)
        }
    }
    
    func addSecret() {
        let newSecret = NewSecret(id: UUID(), variable: "", value: "")
        secrets.append(newSecret)
    }
    
    func removeSecret(_ secret: NewSecret) {
        let index = secrets.firstIndex(of: secret)
        if let index = index {
            secrets.remove(at: index)
        }
    }
}

struct AddSecretView: View {
    @Binding var isPresented: Bool
    @State private var variable = ""
    @State private var value = ""
    @EnvironmentObject var secretsManager: SecretsManager
    @StateObject private var viewModel = SecretsViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Add Secret")
                .font(.title)
            LazyVStack {
                ForEach($viewModel.secrets) { $secret in
                    HStack {
                        TextField("Variable", text: Binding(
                            get: { secret.variable },
                            set: { viewModel.updateSecret(id: secret.id, variable: $0, value: secret.value) }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Value", text: Binding(
                            get: { secret.value },
                            set: { viewModel.updateSecret(id: secret.id, variable: secret.variable, value: $0) }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        if $viewModel.secrets.count > 1 {
                            Button(action: { viewModel.removeSecret(secret) }) {
                                Image(systemName: "minus")
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
           
            HStack {
                Button(role: .cancel, action: {
                    isPresented.toggle()
                }) {
                    Text("Cancel")
                        .padding(4)
                }
                Spacer()
                HStack {
                    Button(action: { viewModel.addSecret()} ) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add more")
                        }
                        .padding(4)
                    }
                    .buttonStyle(.bordered)
                    Button(action: saveSecret) {
                        Text("Save")
                            .padding(4)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValid())
                }
                
            }
            .padding(.top, 16)
        }
        .padding()
    }
    
    func saveSecret() {
        for secret in viewModel.secrets {
            secretsManager.addItem(key: secret.variable, value: secret.value)
        }
        isPresented.toggle()
    }
    
    func isValid() -> Bool {
        for secret in viewModel.secrets {
            if secret.variable.isEmpty || secret.value.isEmpty {
                return false
            }
        }
        return true
    }
}

#Preview("Add Secret") {
    @Previewable @State var isPresented = false
    AddSecretView(isPresented: $isPresented)
}
