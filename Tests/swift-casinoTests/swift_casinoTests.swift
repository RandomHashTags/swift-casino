import XCTest
@testable import SwiftCasino

final class swift_casinoTests: XCTestCase {
    func testExample() throws {
    }
    
    func test_aces() {
        let hand:Hand = Hand(
            player: nil,
            type: CardHolderType.house,
            cards: [
                Card(number: CardNumber.ace, face: CardFace.up),
                Card(number: CardNumber.ace, face: CardFace.up),
                Card(number: CardNumber.ace, face: CardFace.up),
                Card(number: CardNumber.two, face: CardFace.up),
                Card(number: CardNumber.eight, face: CardFace.up)
            ],
            wagers: [:]
        )
        let scores:Set<Int> = hand.scores(game: GameType.blackjack)
        XCTAssertEqual(scores.sorted(by: { $0 < $1 }), [13, 23, 33, 43])
    }
}
