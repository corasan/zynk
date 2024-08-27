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
    @EnvironmentObject var secretsManager: SecretsManager

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
        .onAppear {
            secretsManager.reload()
        }
        .onChange(of: secretsManager.profileName) {oldVal, newVal in
            secretsManager.reload()
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

//#Preview {
//    SecretsTable()
//    SecretsTable(profile: Binding(
//        get: { "development" },
//        set: { newValue in }
//    ))
//}