import SwiftUI

struct FolderPreviewView: View {
    let url: URL
    let result: FolderScanResult

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            content
            if result.truncated || result.error != nil {
                Divider()
                footer
            }
        }
        .background(.background)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "folder.fill")
                .foregroundStyle(.tint)
            Text(url.lastPathComponent)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            Text(itemCountLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var content: some View {
        if let error = result.error {
            VStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text(error)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        } else if result.entries.isEmpty {
            Text("Empty folder")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Table(result.entries) {
                TableColumn("Name") { entry in
                    HStack(spacing: 6) {
                        Image(systemName: entry.isDirectory ? "folder" : "doc")
                            .foregroundColor(entry.isDirectory ? .accentColor : .secondary)
                        Text(entry.name)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                TableColumn("Kind") { entry in
                    Text(entry.kind)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                TableColumn("Size") { entry in
                    Text(formatSize(entry.size))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                TableColumn("Modified") { entry in
                    Text(formatDate(entry.modifiedAt))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
    }

    private var footer: some View {
        HStack {
            if result.truncated {
                Text("Showing \(result.entries.count) of \(result.totalCount) items")
            }
            Spacer()
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    private var itemCountLabel: String {
        switch result.totalCount {
        case 0: return "Empty"
        case 1: return "1 item"
        default: return "\(result.totalCount) items"
        }
    }

    private func formatSize(_ size: Int64?) -> String {
        guard let size else { return "—" }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "—" }
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: date)
    }
}

#Preview {
    FolderPreviewView(
        url: URL(fileURLWithPath: "/tmp/Demo"),
        result: FolderScanResult(
            entries: [
                FolderEntry(id: URL(fileURLWithPath: "/tmp/Demo/Photos"),
                            name: "Photos",
                            url: URL(fileURLWithPath: "/tmp/Demo/Photos"),
                            isDirectory: true,
                            size: nil,
                            modifiedAt: Date(),
                            kind: "Folder"),
                FolderEntry(id: URL(fileURLWithPath: "/tmp/Demo/readme.md"),
                            name: "readme.md",
                            url: URL(fileURLWithPath: "/tmp/Demo/readme.md"),
                            isDirectory: false,
                            size: 1842,
                            modifiedAt: Date(),
                            kind: "Markdown")
            ],
            totalCount: 2,
            truncated: false,
            error: nil
        )
    )
    .frame(width: 640, height: 360)
}
