//
//  SecretsTable.swift
//  EASManager
//
//  Created by Henry on 8/25/24.
//

import SwiftUI

struct EnvVariablesTable: View {
    @State private var showAddSheet = false
    @State private var selectedRows: Set<Variable.ID> = []
    @State private var sortOrder = [KeyPathComparator(\Variable.variable)]
    @State private var showPopOver = false
    @EnvironmentObject var envsModel: EnvVariablesModel
    
    var body: some View {
        VStack(spacing: 0) {
            Dropzone {
                Table(envsModel.variables, selection: $selectedRows) {
                    TableColumn("Variable", value: \.variable)
                    TableColumn("Value", value: \.value)
                }
            }
                        
            HStack {
                AddEnvVariableButton()

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
        .environmentObject(envsModel)
        .onAppear {
            envsModel.reload()
        }
        .onChange(of: envsModel.profileName) {oldVal, newVal in
            envsModel.reload()
        }
        .onChange(of: (envsModel.didUpload)) { oldVal, newVal in
            if newVal {
                envsModel.reload()
                envsModel.didUpload = false
            }
        }
    }
    
    func addItem() {
        showAddSheet.toggle()
    }
    
    func removeItem() {
        if !envsModel.variables.isEmpty {
            for row in selectedRows {
                if let index = envsModel.variables.firstIndex(where: { $0.id == row.self }) {
                    envsModel.removeItem(at: IndexSet(integer: index))
                }
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var envsModel = EnvVariablesModel()
    EnvVariablesTable()
        .environmentObject(envsModel)
}
