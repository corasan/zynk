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

struct AddSecretView: View {
    @Binding var isPresented: Bool
    @State private var variable = ""
    @State private var value = ""
    @EnvironmentObject var secretsManager: SecretsManager
    @StateObject private var newSecretModel = NewSecretModel()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Create")
                .font(.title)
            LazyVStack {
                ForEach($newSecretModel.secrets) { $secret in
                    HStack {
                        TextField("Variable", text: Binding(
                            get: { secret.variable },
                            set: { newSecretModel.updateSecret(id: secret.id, variable: $0, value: secret.value) }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Value", text: Binding(
                            get: { secret.value },
                            set: { newSecretModel.updateSecret(id: secret.id, variable: secret.variable, value: $0) }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        if $newSecretModel.secrets.count > 1 {
                            Button(action: { newSecretModel.removeSecret(secret) }) {
                                Image(systemName: "minus")
                            }
                        }
                    }
                }
                .fontWeight(.medium)
            }
           
            HStack {
                Button(role: .cancel, action: {
                    isPresented.toggle()
                }) {
                    Text("Cancel")
                        .padding(4)
                }
                Spacer()
                HStack {
                    Button(action: { newSecretModel.addSecret()} ) {
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
            .fontWeight(.medium)
            .padding(.top, 16)
        }
        .padding()
    }
    
    func saveSecret() {
        for secret in newSecretModel.secrets {
            secretsManager.addItem(key: secret.variable, value: secret.value)
        }
        isPresented.toggle()
    }
    
    func isValid() -> Bool {
        for secret in newSecretModel.secrets {
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
