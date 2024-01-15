import XCTest
@testable import swift_blackjack

final class swift_blackjackTests: XCTestCase {
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
            wager: 0
        )
        let scores:Set<Int> = hand.scores(game: GameType.blackjack)
        XCTAssertEqual(scores.sorted(by: { $0 < $1 }), [13, 23, 33, 43])
    }
}
