# SafeDeleteRow

A specialized SwiftUI list row wrapper engineered to replace the native `EditButton()` behavior by providing a strict, two-step deletion mechanism that explicitly prevents implicit swipe-to-delete gestures.

## Overview

In native SwiftUI, implementing deletion via an edit state inherently couples the UI with a swipe-to-delete gesture. If a `List` allows a user to delete a row by tapping a leading minus button, the framework automatically permits the user to swipe that row horizontally to delete it.

`SafeDeleteRow` decouples this behavior. It provides a custom list row wrapper that replicates the native edit environment visuals (the leading indicator) and the two-step deletion flow (tap to slide -> tap to delete), while strictly disabling the standard swipe-to-delete functionality. This allows developers to enforce intentional, button-driven interactions without native gestures interfering.

## Requirements

* iOS 15.0+ / macOS 12.0+ / watchOS 8.0+ / tvOS 15.0+
* Swift 5.5+
* Strict Concurrency Ready (`@MainActor` compliant)

## Installation

Add `SafeDeleteRow` to your project using Swift Package Manager directly within Xcode:

1. Open your project in Xcode.
2. In the top menu bar, navigate to **File** > **Add Package Dependencies...**
3. In the search bar located in the top right corner of the window, paste the URL of this repository.
4. Set the **Dependency Rule** to **Up to Next Major Version**.
5. Click **Add Package**.
6. In the final prompt, ensure the `SafeDeleteRow` library is checked and assigned to your main application target, then click **Add Package** again.

## Usage

To utilize `SafeDeleteRow`, bypass the native `EditButton()` and `\.editMode` environment. Instead, manage your editing state with a standard `@State` boolean. Wrap your row content inside the `SafeDeleteRow` view and pass the boolean down.

### Implementation Example

```swift
import SwiftUI
import SafeDeleteRow

struct Item: Identifiable {
    let id = UUID()
    let title: String
}

struct ContentView: View {
    @State private var items = [
        Item(title: "Record 1"),
        Item(title: "Record 2"),
        Item(title: "Record 3")
    ]
    
    // 1. Manage edit state explicitly
    @State private var isEditing: Bool = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    // 2. Wrap your row content and provide the deletion intent
                    SafeDeleteRow(isEditing: isEditing) {
                        delete(item)
                    } content: {
                        Text(item.title)
                            .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Records")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // 3. Toggle the state using a standard Button
                    Button(isEditing ? "Done" : "Edit") {
                        withAnimation(.easeInOut) {
                            isEditing.toggle()
                        }
                    }
                }
            }
        }
    }
    
    private func delete(_ item: Item) {
        items.removeAll { $0.id == item.id }
    }
}
```

## API Reference

```swift
public init(
    isEditing: Bool,
    onDelete: @escaping @MainActor () -> Void,
    @ViewBuilder content: () -> Content
)
```

* **isEditing**: A `Bool` dictating the visual state of the row. When `true`, a leading deletion indicator is presented.
* **onDelete**: A `@MainActor` closure executed only when the trailing, revealed delete button is tapped.
* **content**: A `@ViewBuilder` returning the primary visual content of the row.

## License

This project is licensed under the MIT License.
