import PassepartoutKit
import XCTest

final class Tests: XCTestCase {
    func test_dummy() {
        var profile = Profile.Builder(activatingModules: true)
        profile.name = "foobar"
        XCTAssertEqual(profile.name, "foobar")
    }
}
