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
        ScrollView(.vertical, showsIndicators: true) {
            ForEach(viewModel.metaData) { data in
                Button(action: {
                    guard let app = NSWorkspace.shared.runningApplications
                        .filter ({ (app: NSRunningApplication) in app.activationPolicy == NSApplication.ActivationPolicy.regular })
                        .filter ({ (app: NSRunningApplication) in app.bundleIdentifier == data.identifier && app.bundleURL?.path == data.url.path }).first
                        else { return }
                    app.activate(options: [])
                }) {
                    ListRowView(metaData: data)
                }
                // これを指定するとボタン内のグレーのViewがなくなり、AppListViewのサイズの透明ボタンができる
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)

                // 横線を引く
                Divider()
            }
        }
        // 子View内の最大サイズにあわせてFitする
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
