//
//  AddSecret.swift
//  EASManager
//
//  Created by Henry on 8/25/24.
//

import SwiftUI

//struct VerticalLabeledContentStyle: LabeledContentStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        VStack(alignment: .leading) {
//            configuration.label
//            configuration.content
//        }
//    }
//}
//
//extension LabeledContentStyle where Self == VerticalLabeledContentStyle {
//    static var vertical: VerticalLabeledContentStyle { .init() }
//}

struct AddSecretButton: View {
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
        .buttonStyle(.plain)
        .sheet(isPresented: $isPresented) {
            AddSecretView(isPresented: $isPresented)
        }
    }
}

struct AddSecretView: View {
    @Binding var isPresented: Bool
    @State private var variable = ""
    @State private var value = ""
    @EnvironmentObject var secretsManager: SecretsManager

    var body: some View {
        VStack(alignment: .leading) {
            Text("Add Secret")
                .font(.title)
            HStack(spacing: 8) {
                TextField("Variable", text: $variable)
                TextField("Value", text: $value)
            }
            HStack {
                Button("Cancel", action: {
                    isPresented.toggle()
                })
                Spacer()
                Button("Save", action: saveSecret)
            }
            .padding(.top, 16)
        }
        .padding()
    }
    
    func saveSecret() {
        secretsManager.addItem(key: variable, value: value)
        isPresented.toggle()
    }
}

#Preview("Add Secret") {
    @Previewable @State var isPresented = false
    AddSecretView(isPresented: $isPresented)
}
