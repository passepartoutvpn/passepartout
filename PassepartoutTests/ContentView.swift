//
//  ContentView.swift
//  PassepartoutTests
//
//  Created by Davide De Rosa on 30/10/22.
//  Copyright © 2022 Davide De Rosa. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
