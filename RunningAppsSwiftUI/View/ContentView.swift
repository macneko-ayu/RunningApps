//
//  ContentView.swift
//  RunningAppsSwiftUI
//
//  Created by Kojiro Yokota on 2020/12/06.
//  Copyright © 2020 macneko.com. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = RunningAppsViewModel()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(viewModel.metaData) { data in
                Button(action: {
                    guard let app = NSWorkspace.shared.runningApplications
                        .filter ({ (app: NSRunningApplication) in app.activationPolicy == NSApplication.ActivationPolicy.regular })
                        .filter ({ (app: NSRunningApplication) in app.bundleIdentifier == data.identifier && app.bundleURL?.path == data.url.path }).first
                        else { return }
                    app.activate(options: [])
                }) {
                    AppListView(metaData: data)
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
