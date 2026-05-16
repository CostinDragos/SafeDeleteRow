@testable import SafeDeleteRow
import SwiftUI
import Testing

@Suite("SafeDeleteRow Structural Tests")
@MainActor
struct SafeDeleteRowTests {
  @Test
  func `Validates Public API Initialization`() {
    var deleteActionTriggered = false
    let isEditing = true

    let subject = SafeDeleteRow(isEditing: isEditing) {
      deleteActionTriggered = true
    } content: {
      Text("Test Content")
    }

    let viewType = type(of: subject)
    #expect(String(describing: viewType).contains("SafeDeleteRow"))
    #expect(!deleteActionTriggered, "Action should not trigger upon initialization")
  }
}
