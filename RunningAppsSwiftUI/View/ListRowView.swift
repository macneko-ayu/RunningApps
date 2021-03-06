//
//  ListRowView.swift
//  RunningApps
//
//  Created by Kojiro Yokota on 2020/12/07.
//  Copyright © 2020 macneko.com. All rights reserved.
//

import SwiftUI

struct ListRowView: View {
    let metaData: ApplicationMetaData

    var body: some View {
        HStack {
            Image(nsImage: metaData.icon ?? NSImage())
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36, alignment: .center)

            VStack(alignment: .leading) {
                Text(metaData.name)
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .padding(.bottom, 7)

                Text(metaData.versionDescription)
                    .font(.system(size: 12, weight: .regular, design: .default))
            }
        }
        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .background(Rectangle().foregroundColor(.clear))
        .contentShape(Rectangle())
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowView(metaData: ApplicationMetaData(name: "dummy name", url: URL(fileURLWithPath: ""),
                                                  identifier: "com.macneko.dummy", version: "0.0.0",  shortVersion: "x.x.x", icon: NSImage(), isRunning: true))
    }
}
