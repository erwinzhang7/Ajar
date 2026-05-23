import Cocoa
import Quartz
import SwiftUI

/// Quick Look preview entry point. The system instantiates this class
/// (declared in Info.plist via `NSExtensionPrincipalClass`) once per preview
/// session and calls `preparePreviewOfFile(at:)` with the file the user pressed
/// Space on. We block here until the contents are scanned so the view is
/// already populated by the time Quick Look puts it on screen.
final class PreviewViewController: NSViewController, QLPreviewingController {

    /// Maximum number of folder entries to render in the preview. Quick Look
    /// previews are meant to be glanceable, and SwiftUI `Table` performance
    /// degrades with very large datasets — when a folder exceeds this cap we
    /// show the first N items and note the remainder in the footer.
    private static let displayCap = 500

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
    }

    func preparePreviewOfFile(at url: URL) async throws {
        let result = await FolderScanner.scan(url: url, cap: Self.displayCap)
        await MainActor.run { [weak self] in
            guard let self else { return }
            self.installRootView(url: url, result: result)
        }
    }

    @MainActor
    private func installRootView(url: URL, result: FolderScanResult) {
        let root = FolderPreviewView(url: url, result: result)
        let hosting = NSHostingView(rootView: root)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        view.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(hosting)
        NSLayoutConstraint.activate([
            hosting.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
