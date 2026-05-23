import SwiftUI

@main
struct AjarApp: App {
    var body: some Scene {
        WindowGroup("Ajar") {
            ContentView()
                .frame(
                    minWidth: 520,
                    idealWidth: 600,
                    minHeight: 400,
                    idealHeight: 460
                )
        }
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
