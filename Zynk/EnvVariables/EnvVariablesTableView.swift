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
    @State private var showEditSheet = false
    @State private var editVariable: Variable?
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
                                    editVariable = variable
                                    print("showEditSheet \(showEditSheet)")
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit")
                                    }
                                }
                                Button(role: .destructive, action: { envsModel.removeItem(id: variable.id) }) {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Delete")
                                    }
                                }
                            }
                    }
                }
            }
            .sheet(item: $editVariable) { variable in
                EditEnvVariableView(item: variable, isPresented: Binding(
                    get: { editVariable != nil },
                    set: { if !$0 { editVariable = nil } }
                ))
            }
                        
            HStack {
                AddEnvVariableButton()

                Button(action: { envsModel.removeSelectedItems(items: selectedRows) }) {
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
}

#Preview {
    @Previewable @StateObject var envsModel = EnvVariablesModel()
    EnvVariablesTable()
        .environmentObject(envsModel)
}
