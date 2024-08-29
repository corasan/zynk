//
//  NewSecret.swift
//  Zynk
//
//  Created by Henry on 8/28/24.
//

import Foundation

struct NewSecret: Identifiable, Equatable {
    let id: UUID
    let variable: String
    let value: String
}

class NewSecretModel: ObservableObject {
    @Published var secrets: [NewSecret] = []
    
    init() {
        secrets = [NewSecret(id: UUID(), variable: "", value: "")]
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
