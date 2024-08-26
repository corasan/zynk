//
//  ContentView.swift
//  EASManager
//
//  Created by Henry on 8/24/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            
            VStack(alignment: .leading) {
                Text("Profiles")
                    .font(.title)
                    .padding(.horizontal)
                List {
                    Text("First")
                }
            }
        } detail: {
            Text("First")
        }
    }
}

#Preview {
    ContentView()
}
