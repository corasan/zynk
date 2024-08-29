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
            AddEnvVariableView(isPresented: $isPresented)
        }
    }
}

struct AddEnvVariableView: View {
    @Binding var isPresented: Bool
    @State private var variable = ""
    @State private var value = ""
    @EnvironmentObject var envsModel: EnvVariablesModel
    @StateObject private var newVariableModel = NewVariableModel()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Create")
                .font(.title)
            LazyVStack {
                ForEach($newVariableModel.variables) { $item in
                    HStack {
                        TextField("Variable", text: Binding(
                            get: { item.variable },
                            set: { newVariableModel.updateNewVariable(id: item.id, variable: $0, value: item.value) }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Value", text: Binding(
                            get: { item.value },
                            set: { newVariableModel.updateNewVariable(id: item.id, variable: item.variable, value: $0) }
                        ))
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
                Button(role: .cancel, action: {
                    isPresented.toggle()
                }) {
                    Text("Cancel")
                        .padding(4)
                }
                Spacer()
                HStack {
                    Button(action: { newVariableModel.addNewVariable()} ) {
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
        for v in newVariableModel.variables {
            envsModel.addItem(key: v.variable, value: v.value)
        }
        isPresented.toggle()
    }
    
    func isValid() -> Bool {
        for v in newVariableModel.variables {
            if v.variable.isEmpty || v.value.isEmpty {
                return false
            }
        }
        return true
    }
}

#Preview("Add Secret") {
    @Previewable @State var isPresented = false
    AddEnvVariableView(isPresented: $isPresented)
}
