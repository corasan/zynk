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
    @State private var selectedRow: Variable.ID?
    @State private var sortOrder = [KeyPathComparator(\Variable.variable)]
    @State private var showPopOver = false
    @EnvironmentObject var envsModel: EnvVariablesModel
    
    var body: some View {
        VStack(spacing: 0) {
            Dropzone {
                Table(of: Variable.self, selection: $selectedRows) {
                    TableColumn("Variable", value: \.variable)
                    TableColumn("Value", value: \.value)
                } rows: {
                    ForEach(envsModel.variables) { variable in
                        TableRow(variable)
                            .contextMenu {
                                Button(action: {
                                    print("Hello World!")
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit")
                                    }
                                }
                                Button(role: .destructive, action: { removeItem(variable.id) }) {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Delete")
                                    }
                                }
                            }
                    }
                }
            }
                        
            HStack {
                AddEnvVariableButton()

                Button(action: removeSelectedRows) {
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
    
    func removeItem(_ id: UUID?) {
        if !envsModel.variables.isEmpty {
            if let index = envsModel.variables.firstIndex(where: { $0.id == id }) {
                envsModel.removeItem(at: IndexSet(integer: index))
            }
        }
    }
    
    func removeSelectedRows() {
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
