

import SwiftUI

struct Level {
    let walkableGrid: [[Bool]]
    let playerStart: [(Int, Int, Direction)]
    let finishPosition: [(Int, Int)]
    let blocks: [(Int, Int)]
    let directionChangers: [(Int, Int, Direction)]
    let restrictedBlocks: [(Int, Int, Direction)]
    let oneDirectionBlocks: [(Int, Int, Direction)]

}


struct LevelState: Codable {
    let levelIndex: Int
    var isOpen: Bool
    var isFinished: Bool
}
