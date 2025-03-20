
import Testing
@testable import SwiftCasino

struct swift_casinoTests {
    @Test
    func testAces() {
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
        #expect(scores.sorted(by: { $0 < $1 }) == [13, 23, 33, 43])
    }
}
