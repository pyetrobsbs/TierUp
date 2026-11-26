//
//  TierUpApp.swift
//  TierUp
//
//  Created by Pedro Henrique on 26/11/2026.
//

import SwiftUI

@main
struct TierUpApp: App {
    // @StateObject: a app cria o TierStore UMA vez e mantém-no vivo
    @StateObject private var store = TierStore()

    var body: some Scene {
        WindowGroup {
            // O primeiro ecrã é a ListasView.
            // .environmentObject partilha o store com todos os ecrãs.
            ListasView()
                .environmentObject(store)
        }
    }
}
