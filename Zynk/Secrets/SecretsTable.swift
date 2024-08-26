//
//  SecretsTable.swift
//  EASManager
//
//  Created by Henry on 8/25/24.
//

import SwiftUI

struct SecretsTable: View {
    @State private var showAddSheet = false
    @State private var selectedRow: Secret.ID?
    @State private var sortOrder = [KeyPathComparator(\Secret.variable)]
    @StateObject var secretsManager: SecretsManager
    @Binding var profileName: String
    
    init(profile: Binding<String>) {
        _profileName = profile
        let secretsManager = SecretsManager(profile: profile.wrappedValue)
        _secretsManager = StateObject(wrappedValue: secretsManager)
    }
    
    var body: some View {
        VStack {
            Table(secretsManager.secrets, selection: $selectedRow, sortOrder: $sortOrder) {
                TableColumn("Variable", value: \.variable)
                TableColumn("Value", value: \.value)
            }
            
            HStack {
                AddSecretButton()

                Button(action: removeItem) {
                    Label("Remove", systemImage: "minus")
                        .foregroundStyle(.foreground)
                        .fontWeight(.medium)
                        .labelStyle(.iconOnly)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(minWidth: 300, minHeight: 200)
        .environmentObject(secretsManager)
        .onChange(of: profileName) { oldValue, newValue in
            secretsManager.profileName = newValue
        }
    }
    
    func addItem() {
        showAddSheet.toggle()
    }
    
    func removeItem() {
        if !secretsManager.secrets.isEmpty {
            if let selected = selectedRow {
                if let index = secretsManager.secrets.firstIndex(where: { $0.id == selected}) {
                    secretsManager.removeItem(at: IndexSet(integer: index))
                }
            }
        }
    }
}

#Preview {
    SecretsTable(profile: Binding(
        get: { "development" },
        set: { newValue in }
    ))
}
