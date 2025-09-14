//
//  ThoughtStreamApp.swift
//  ThoughtStream
//
//  Created by Hugo L on 2025-08-30.
//

import SwiftUI
import SwiftData

@main
struct ThoughtStreamApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            ConversationEntity.self,
            ChatMessageEntity.self,
            SystemMessageEntity.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
