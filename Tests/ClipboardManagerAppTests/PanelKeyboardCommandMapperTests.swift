import Foundation
import Testing
@testable import ClipboardManagerApp

struct PanelKeyboardCommandMapperTests {
    @Test
    func mapsArrowAndActionKeys() {
        let mapper = PanelKeyboardCommandMapper()

        #expect(mapper.command(for: 126) == .moveUp)
        #expect(mapper.command(for: 125) == .moveDown)
        #expect(mapper.command(for: 36) == .confirmSelection)
        #expect(mapper.command(for: 53) == .dismissPanel)
        #expect(mapper.command(for: 0) == nil)
    }
}
