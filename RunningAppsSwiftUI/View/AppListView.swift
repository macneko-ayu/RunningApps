//
//  AppListView.swift
//  RunningApps
//
//  Created by Kojiro Yokota on 2020/12/07.
//  Copyright © 2020 macneko.com. All rights reserved.
//

import SwiftUI

struct AppListView: View {
    let metaData: ApplicationMetaData

    var body: some View {
        HStack {
            Image(nsImage: metaData.icon ?? NSImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading) {
                Text(metaData.name).fontWeight(.bold)
                Text(metaData.versionDescription)
            }
        }
        .padding(8)
    }
}

struct AppListView_Previews: PreviewProvider {
    static var previews: some View {
        AppListView(metaData: ApplicationMetaData(name: "dummy name", url: URL(fileURLWithPath: ""),
                                                  identifier: "com.macneko.dummy", version: "0.0.0", icon: NSImage(), isRunning: true))
    }
}
