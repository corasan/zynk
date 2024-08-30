//
//  EditEnvVariableView.swift
//  Zynk
//
//  Created by Henry on 8/29/24.
//

import SwiftUI

struct EditEnvVariableView: View {
    @State private var variable: String
    @State private var value: String
    @Binding var isPresented: Bool
    @EnvironmentObject var envsModel: EnvVariablesModel
    @Environment(\.dismiss) private var dismiss
    private var variableItem: Variable
    
    
    init(item: Variable, isPresented: Binding<Bool>) {
        _variable = State(initialValue: item.variable)
        _value = State(initialValue: item.value)
        _isPresented = isPresented
        variableItem = item
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Variable", text: $variable)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Value", text: $value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .fontWeight(.medium)
            
            HStack {
                Button(role: .cancel, action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .padding(4)
                }
                Spacer()
                Button(action: saveChanges) {
                    Text("Save")
                        .padding(4)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isValid())
            }
            .fontWeight(.medium)
            .padding(.top, 16)
        }
        .padding()
    }
    
    func saveChanges() {
        if let index = envsModel.variables.firstIndex(of: variableItem) {
            envsModel.editItem(at: index, key: variable, value: value)
            dismiss()
        }
    }
    
    func isValid() -> Bool {
        return !variable.isEmpty && !value.isEmpty
    }
}

#Preview {
    @Previewable @State var isPresented = true
    EditEnvVariableView(item: Variable(variable: "ZYNK_API_KEY", value: "YOUR_API_KEY_HERE"), isPresented: $isPresented)
}
