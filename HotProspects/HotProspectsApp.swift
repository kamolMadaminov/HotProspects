//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by Kamol Madaminov on 16/04/25.
//

import SwiftData
import SwiftUI

@main
struct HotProspectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Prospect.self)
    }
}
