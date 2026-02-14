//
//  ClipboardHistoryView.swift
//  Copyer
//

import SwiftUI

struct ClipboardHistoryView: View {
    @ObservedObject var historyStore: HistoryStore
    var onSelectItem: (ClipboardItem) -> Void
    var onDismiss: () -> Void

    @State private var selectedIndex: Int = 0
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if historyStore.items.isEmpty {
                Text("No clipboard history")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                ScrollViewReader { proxy in
                    List(Array(historyStore.items.enumerated()), id: \.element.id) { index, item in
                        ClipboardRowView(item: item, isSelected: index == selectedIndex)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedIndex = index
                                onSelectItem(historyStore.items[index])
                            }
                            .id(index)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .onAppear {
                        proxy.scrollTo(0, anchor: .top)
                    }
                    .onChange(of: selectedIndex) { _, newValue in
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
        .frame(width: 320, height: 400)
        .focusable(!historyStore.items.isEmpty)
        .focused($isFocused)
        .onAppear {
            selectedIndex = 0
            isFocused = !historyStore.items.isEmpty
        }
        .onKeyPress(.upArrow) {
            if historyStore.items.count > 0 {
                selectedIndex = max(selectedIndex - 1, 0)
            }
            return .handled
        }
        .onKeyPress(.downArrow) {
            if historyStore.items.count > 0 {
                selectedIndex = min(selectedIndex + 1, historyStore.items.count - 1)
            }
            return .handled
        }
        .onKeyPress(.return) {
            if selectedIndex >= 0, selectedIndex < historyStore.items.count {
                onSelectItem(historyStore.items[selectedIndex])
            }
            return .handled
        }
        .onKeyPress(.escape) {
            onDismiss()
            return .handled
        }
    }
}

private struct ClipboardRowView: View {
    let item: ClipboardItem
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.preview)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .foregroundStyle(isSelected ? .white : .primary)
            Text(item.date, style: .time)
                .font(.caption)
                .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color.accentColor : Color.clear)
    }
}

#Preview {
    ClipboardHistoryView(
        historyStore: {
            let s = HistoryStore()
            s.add(ClipboardItem(content: "First copied text"))
            s.add(ClipboardItem(content: "Second copied text that is a bit longer"))
            return s
        }(),
        onSelectItem: { _ in },
        onDismiss: { }
    )
}
