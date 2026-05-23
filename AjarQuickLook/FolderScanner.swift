import Foundation

struct FolderEntry: Identifiable, Hashable {
    let id: URL
    let name: String
    let url: URL
    let isDirectory: Bool
    let size: Int64?
    let modifiedAt: Date?
    let kind: String
}

struct FolderScanResult {
    let entries: [FolderEntry]
    let totalCount: Int
    let truncated: Bool
    let error: String?

    static let empty = FolderScanResult(entries: [], totalCount: 0, truncated: false, error: nil)
}

enum FolderScanner {
    /// Reads the immediate children of `url` off the main actor and returns
    /// up to `cap` entries (folders first, then alphabetical). The cap exists
    /// so a Quick Look preview of a 50,000-file folder doesn't pin the CPU
    /// or stall layout — we still report the true total so the UI can say
    /// "showing X of Y."
    static func scan(url: URL, cap: Int) async -> FolderScanResult {
        await Task.detached(priority: .userInitiated) {
            let keys: Set<URLResourceKey> = [
                .isDirectoryKey,
                .fileSizeKey,
                .totalFileSizeKey,
                .contentModificationDateKey,
                .localizedTypeDescriptionKey
            ]

            let fm = FileManager.default
            let children: [URL]
            do {
                children = try fm.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: Array(keys),
                    options: [.skipsHiddenFiles]
                )
            } catch {
                return FolderScanResult(
                    entries: [],
                    totalCount: 0,
                    truncated: false,
                    error: "Couldn’t read folder: \(error.localizedDescription)"
                )
            }

            let total = children.count
            let limited = Array(children.prefix(cap))

            let mapped: [FolderEntry] = limited.map { child in
                let values = try? child.resourceValues(forKeys: keys)
                let isDir = values?.isDirectory ?? false
                let size: Int64? = {
                    guard !isDir else { return nil }
                    if let s = values?.fileSize { return Int64(s) }
                    if let s = values?.totalFileSize { return Int64(s) }
                    return nil
                }()
                return FolderEntry(
                    id: child,
                    name: child.lastPathComponent,
                    url: child,
                    isDirectory: isDir,
                    size: size,
                    modifiedAt: values?.contentModificationDate,
                    kind: values?.localizedTypeDescription ?? (isDir ? "Folder" : "File")
                )
            }

            let sorted = mapped.sorted { lhs, rhs in
                if lhs.isDirectory != rhs.isDirectory {
                    return lhs.isDirectory && !rhs.isDirectory
                }
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }

            return FolderScanResult(
                entries: sorted,
                totalCount: total,
                truncated: total > limited.count,
                error: nil
            )
        }.value
    }
}
