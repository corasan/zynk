//
//  AddSecret.swift
//  EASManager
//
//  Created by Henry on 8/25/24.
//

import SwiftUI

struct AddEnvVariableButton: View {
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
            AddEnvVariableView()
        }
    }
}

struct AddEnvVariableView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var envsModel: EnvVariablesModel
    @StateObject private var newVariableModel = NewVariableModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Create")
                .font(.title)
            LazyVStack {
                ForEach($newVariableModel.variables) { $item in
                    HStack {
                        TextField("Variable", text: $item.variable)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Value", text: $item.value)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if newVariableModel.variables.count > 1 {
                            Button(action: { newVariableModel.removeNewVariable(item) }) {
                                Image(systemName: "minus")
                            }
                        }
                    }
                }
                .fontWeight(.medium)
            }
            
            HStack {
                Button(role: .cancel, action: { dismiss() }) {
                    Text("Cancel")
                        .padding(4)
                }
                Spacer()
                HStack {
                    Button(action: { newVariableModel.addNewVariable() } ) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add more")
                        }
                        .padding(4)
                    }
                    .buttonStyle(.bordered)
                    Button(action: saveVariable) {
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
    
    func saveVariable() {
        for v in newVariableModel.variables {
            envsModel.addItem(key: v.variable, value: v.value)
        }
        dismiss()
    }
    
    func isValid() -> Bool {
        !newVariableModel.variables.contains { $0.variable.isEmpty || $0.value.isEmpty }
    }
}

#Preview("Add Secret") {
    AddEnvVariableView()
}
