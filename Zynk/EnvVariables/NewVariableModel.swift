//
//  NewSecret.swift
//  Zynk
//
//  Created by Henry on 8/28/24.
//

import Foundation

//struct NewVariable Identifiable, Equatable {
//    let id: UUID
//    let variable: String
//    let value: String
//}

class NewVariableModel: ObservableObject {
    @Published var variables: [Variable] = []
    
    init() {
        variables = [Variable(variable: "", value: "")]
    }
    
    func updateNewVariable(id: UUID, variable: String, value: String) {
        if let index = variables.firstIndex(where: { $0.id == id }) {
            variables[index] = Variable(variable: variable, value: value)
        }
    }
    
    func addNewVariable() {
        let newVariable = Variable(variable: "", value: "")
        variables.append(newVariable)
    }
    
    func removeNewVariable(_ variable: Variable) {
        let index = variables.firstIndex(of: variable)
        if let index = index {
            variables.remove(at: index)
        }
    }
}
