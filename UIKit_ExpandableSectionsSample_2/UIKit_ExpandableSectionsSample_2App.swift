//
//  UIKit_ExpandableSectionsSample_2App.swift
//  UIKit_ExpandableSectionsSample_2
//
//  Created by Yuki Sasaki on 2025/09/21.
//

import SwiftUI

@main
struct UIKit_ExpandableSectionsSample_2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
