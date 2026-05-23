import SwiftUI
import AppKit

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            Divider()
            instructions
            Spacer(minLength: 0)
            footer
        }
        .padding(24)
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "doc.text.magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 2) {
                Text("Ajar")
                    .font(.title.bold())
                Text("Folder and archive previews for macOS Quick Look")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var instructions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Turn on the extension")
                .font(.headline)
            Text("Ajar runs as a system Quick Look extension. Enable it once and it works everywhere Quick Look does — Finder, ForkLift, Path Finder, and other file managers.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                Step(number: 1, text: "Open System Settings → General → Login Items & Extensions.")
                Step(number: 2, text: "Scroll to Extensions and click the (i) next to “Quick Look”.")
                Step(number: 3, text: "Toggle Ajar on.")
                Step(number: 4, text: "Select a folder in Finder and press Space.")
            }
            .padding(.top, 6)
        }
    }

    private var footer: some View {
        HStack {
            Button {
                openExtensionsSettings()
            } label: {
                Label("Open Login Items & Extensions", systemImage: "gearshape")
            }
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)

            Spacer()

            Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0")")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private func openExtensionsSettings() {
        // macOS 13+: System Settings pane for Login Items & Extensions.
        // macOS 12:  falls back to the legacy Extensions preference pane.
        let candidates = [
            "x-apple.systempreferences:com.apple.LoginItems-Settings.extension",
            "x-apple.systempreferences:com.apple.preferences.extensions"
        ]
        for raw in candidates {
            if let url = URL(string: raw), NSWorkspace.shared.open(url) {
                return
            }
        }
    }
}

private struct Step: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(number).")
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 18, alignment: .trailing)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 600, height: 460)
}
