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

    var body: some View {
        VStack(alignment: .leading) {
            Text("Add Secret")
                .font(.title)
            HStack(spacing: 8) {
                TextField("Variable", text: $variable)
                TextField("Value", text: $value)
            }
            HStack {
                Button("Cancel",role: .cancel, action: {
                    isPresented.toggle()
                })
                Spacer()
                Button("Save", action: saveSecret)
                    .buttonStyle(.borderedProminent)
                    .disabled(variable.isEmpty || value.isEmpty)
            }
            .padding(.top, 16)
        }
        .padding()
    }
    
    func saveSecret() {
        secretsManager.addItem(key: variable, value: value)
        isPresented.toggle()
    }
}

#Preview("Add Secret") {
    @Previewable @State var isPresented = false
    AddSecretView(isPresented: $isPresented)
}
