//
//  JasperDemoApp.swift
//  JasperDemo
//
//  Created by Jonathan Wight on 6/16/23.
//

import SwiftUI

@main
struct JasperDemoApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        DocumentGroup(viewing: JasperDocument.self) { configuration in

            let document = configuration.document

            JasperStructureView(operations: .constant([document.operation]))
        }
    }
}
