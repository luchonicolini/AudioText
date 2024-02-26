//
//  ContentView.swift
//  AudioText
//
//  Created by Luciano Nicolini on 26/02/2024.
//

import SwiftUI

struct ContentView: View {
  @State private var showSheet = false

  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")
      
      Button("Open Sheet") {
        showSheet = true
      }
    }
    .padding()
    .sheet(isPresented: $showSheet) {
      AudioTextView()
    }
  }
}


#Preview {
    ContentView()
}
