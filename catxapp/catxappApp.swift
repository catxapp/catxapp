//
//  catxappApp.swift
//  catxapp
//

import SwiftUI

@main
struct catxappApp: App {
    @State private var appModel = AppModel()
    @State private var isReady = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .opacity(isReady ? 1 : 0)

                if !isReady {
                    LaunchSplashView()
                        .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.25), value: isReady)
            .environment(appModel)
            .preferredColorScheme(.dark)
            .task {
                await appModel.bootstrap()
                isReady = true
            }
        }
    }
}
