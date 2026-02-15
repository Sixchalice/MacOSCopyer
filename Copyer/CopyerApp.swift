//
//  CopyerApp.swift
//  Copyer
//
//  Created by Noam Ram on 2/14/26.
//

import SwiftUI

@main
struct CopyerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
