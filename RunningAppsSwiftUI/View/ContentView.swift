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
                        // TODO: widthを指定しないと左揃えにならない。他のView Modifiersがありそう
                        .frame(width: viewModel.windowMinWidth, height: viewModel.rowMinHeight, alignment: .leading)
                }
                // これを指定するとボタン内のグレーのViewがなくなり、AppListViewのサイズの透明ボタンができる
                .buttonStyle(PlainButtonStyle())

                // 横線を引く
                Divider()
            }
        }
        // AppListViewのpaddingを加味して、足りない天地の余白だけ指定
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        // 子View内の最大サイズにあわせてFitする
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
