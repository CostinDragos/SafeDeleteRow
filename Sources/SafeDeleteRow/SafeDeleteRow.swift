import SwiftUI

/// A custom list row wrapper that provides a safe, two-step deletion process
/// in Edit Mode, completely avoiding accidental horizontal swipe gestures.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@MainActor
public struct SafeDeleteRow<Content: View>: View {
  private let isEditing: Bool

  /// Internal state to track if the Delete button is currently exposed
  @State private var isRevealed: Bool = false

  /// The action to perform when "Delete" is tapped
  private let onDelete: @MainActor () -> Void

  /// The content of the row
  private let content: Content

  /// Initializes a new SafeDeleteRow.
  /// - Parameters:
  ///   - isEditing: A boolean tracking whether the list is currently in Edit Mode.
  ///   - onDelete: The action to execute when the delete button is tapped.
  ///   - content: A view builder that creates the visual content of the row.
  public init(
    isEditing: Bool,
    onDelete: @escaping @MainActor () -> Void,
    @ViewBuilder content: () -> Content,
  ) {
    self.isEditing = isEditing
    self.onDelete = onDelete
    self.content = content()
  }

  public var body: some View {
    ZStack(alignment: .trailing) {
      // MARK: - The Background Delete Layer (RHS)

      Button(role: .destructive) {
        withAnimation {
          isRevealed = false
          onDelete()
        }
      } label: {
        Text("Delete")
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .frame(maxHeight: .infinity)
          .frame(width: 100)
          .background(Color.red)
          .contentShape(Rectangle())
      }
      .buttonStyle(.borderless)
      .padding(.trailing, -20)
      .padding(.vertical, -16)
      .opacity(isRevealed ? 1 : 0)

      // MARK: - The Main Content Layer

      HStack(spacing: 0) {
        // The Minus Button (LHS)
        if isEditing {
          Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
              isRevealed.toggle()
            }
          } label: {
            Image(systemName: "minus.circle.fill")
              .foregroundColor(.red)
              .font(.title2)
          }
          .buttonStyle(.plain)
          .padding(.trailing, 12)
          // Beautiful slide-in transition from the left
          .transition(.move(edge: .leading).combined(with: .opacity))
        }

        // The Developer's Custom UI
        content
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      // Slide the entire row left to reveal the delete button
      .offset(x: isRevealed ? -80 : 0)
      .allowsHitTesting(!isRevealed)

      // MARK: - The Cancellation Layer

      // If the delete button is revealed, cover the content with an invisible shield.
      // If the user taps the shield, hide the delete button instead of triggering the row!
      .overlay {
        if isRevealed {
          Color.white.opacity(0.001)
            .contentShape(Rectangle())
            .padding(.trailing, 80)
            .onTapGesture {
              withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isRevealed = false
              }
            }
            .gesture(
              DragGesture(minimumDistance: 20)
                .onEnded { value in
                  if value.translation.width > 0 {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                      isRevealed = false
                    }
                  }
                },
            )
        }
      }
    }

    // MARK: - State Management

    // If the user taps "Done" on the edit button, ensure we close the revealed row
    .onChange(of: isEditing) { newValue in
      if newValue == false {
        withAnimation {
          isRevealed = false
        }
      }
    }
  }
}
