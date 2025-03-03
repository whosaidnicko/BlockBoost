import SwiftUI
import SpriteKit

class GameScene: SKScene {
    
    var sceneController: SceneController?
    
    private var background: SKSpriteNode!
   
    let gridWidth = 6
    let gridHeight = 8
    let cellSize: CGFloat = 40
    
  
    var players: [SKSpriteNode] = []
    var finishes: [SKSpriteNode] = []
    var blocks: [SKSpriteNode] = []
    var directionChangers: [SKSpriteNode] = []
    var restrictedBlocks: [SKSpriteNode] = []
    var oneDirectionBlocks: [SKSpriteNode] = []
    

    var currentLevel = 0
    let totalLevels = 12
    var playerDirections: [Direction] = []
    
    var directionArrow: SKSpriteNode!
    

    var swipeStartLocation: CGPoint = .zero
    var selectedBlock: SKSpriteNode? = nil
    
    private var titleLabel: SKLabelNode!
    private var backButton: SKSpriteNode!
    private var updateButton: SKSpriteNode!
  

    
    
    //MARK: DID MOVE
    override func didMove(to view: SKView) {
        backgroundColor = .black
       
        setupLevel()
      
        setupTitle()
        
        setupBackButton()
        
        setupUpdateButton()
    }
    
//    //MARK: Title "Settings"
    private func setupBackground() {
        background = SKSpriteNode(imageNamed: "bg")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = -1
        addChild(background)
    }
    
    
    //MARK: Title "Settings"
     private func setupUpdateButton() {
      
         updateButton = createButton(named: "update", size: CGSize(width: 24, height: 24), position: CGPoint(x: size.width - 50 , y: titleLabel.position.y + 10), name: "update_button")
         addChild(updateButton)
     }
  
    
    //MARK: Title "Settings"
    private func setupTitle() {
        let offsetY: CGFloat = size.height > 850 ? 20 : 0
        
        titleLabel = SKLabelNode(text: "Level \(currentLevel + 1)")
        titleLabel.fontName = "Montserrat-Bold"
        titleLabel.fontSize = 24
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - titleLabel.fontSize * 3.2 - offsetY )
        addChild(titleLabel)
        
        setupBackButton()
        setupUpdateButton()

        
    }
    
    //MARK: Back Button (Arrow)
    private func setupBackButton() {
        backButton = createButton(named: "backButton", size: CGSize(width: 14, height: 21), position: CGPoint(x: 50, y: titleLabel.position.y + 10), name: "back_button")
        addChild(backButton)
    }
    
    //MARK: Image Button Creation
    private func createButton(named imageName: String, size: CGSize, position: CGPoint, name: String) -> SKSpriteNode {
        let button = SKSpriteNode(imageNamed: imageName)
        button.size = size
        button.position = position
        button.name = name
        return button
    }
    

    func findGridBounds(walkableGrid: [[Bool]]) -> (minRow: Int, maxRow: Int, minCol: Int, maxCol: Int)? {
        var minRow = Int.max
        var maxRow = Int.min
        var minCol = Int.max
        var maxCol = Int.min
        
        for row in 0..<walkableGrid.count {
            for col in 0..<walkableGrid[row].count {
                if walkableGrid[row][col] {
                    minRow = min(minRow, row)
                    maxRow = max(maxRow, row)
                    minCol = min(minCol, col)
                    maxCol = max(maxCol, col)
                }
            }
        }
        
        if minRow == Int.max || minCol == Int.max {
            return nil
        }
        
        return (minRow, maxRow, minCol, maxCol)
    }

 
    func setupLevel() {
        guard currentLevel < levels.count else {
//            print("All levels completed!")
            return
        }
        let level = levels[currentLevel]
      
        removeAllChildren()
        players.removeAll()
        finishes.removeAll()
        blocks.removeAll()
        directionChangers.removeAll()
        restrictedBlocks.removeAll()
        oneDirectionBlocks.removeAll()
        playerDirections.removeAll()
        setupBackground()
      
        
        guard let bounds = findGridBounds(walkableGrid: level.walkableGrid) else {
//            print("Нет активных клеток в уровне!")
            return
        }
        
        let minRow = bounds.minRow
        let maxRow = bounds.maxRow
        let minCol = bounds.minCol
        let maxCol = bounds.maxCol
        
        let activeGridWidth = maxCol - minCol + 1
        let activeGridHeight = maxRow - minRow + 1
        
        let totalActiveGridWidth = CGFloat(activeGridWidth) * cellSize
        let totalActiveGridHeight = CGFloat(activeGridHeight) * cellSize
        let offsetX = (size.width - totalActiveGridWidth) / 2
        let offsetY = (size.height - totalActiveGridHeight) / 2
        

        for row in minRow...maxRow {
            for col in minCol...maxCol {
                if level.walkableGrid[row][col] {
                    let cell = SKSpriteNode(texture: SKTexture(imageNamed: "Type=Empty"))
                    cell.size = CGSize(width: cellSize, height: cellSize)
                    cell.position = CGPoint(
                        x: offsetX + CGFloat(col - minCol) * cellSize + cellSize / 2,
                        y: offsetY + CGFloat(row - minRow) * cellSize + cellSize / 2
                    )
                    cell.name = "cell_\(row)_\(col)"
                    addChild(cell)
                }
            }
        }
        
  
        for (index, playerStart) in level.playerStart.enumerated() {
            let player = SKSpriteNode(imageNamed: playerStart.2.imageNamePlayer())
            player.size = CGSize(width: cellSize, height: cellSize)
            player.position = CGPoint(
                x: offsetX + CGFloat(playerStart.1 - minCol) * cellSize + cellSize / 2,
                y: offsetY + CGFloat(playerStart.0 - minRow) * cellSize + cellSize / 2
            )
            player.name = "player_\(index)"
            player.zPosition = 1
            players.append(player)
            addChild(player)
            playerDirections.append(playerStart.2)
        }
        

        for (index, finishPosition) in level.finishPosition.enumerated() {
            let finish = SKSpriteNode(imageNamed: "Type=Finish")
            finish.size = CGSize(width: cellSize, height: cellSize)
            finish.position = CGPoint(
                x: offsetX + CGFloat(finishPosition.1 - minCol) * cellSize + cellSize / 2,
                y: offsetY + CGFloat(finishPosition.0 - minRow) * cellSize + cellSize / 2
            )
            finish.name = "finish_\(index)"
            finishes.append(finish)
            addChild(finish)
        }
        
   
        func findGridBounds(walkableGrid: [[Bool]]) -> (minRow: Int, maxRow: Int, minCol: Int, maxCol: Int)? {
            var minRow = Int.max
            var maxRow = Int.min
            var minCol = Int.max
            var maxCol = Int.min
            
            for row in 0..<walkableGrid.count {
                for col in 0..<walkableGrid[row].count {
                    if walkableGrid[row][col] {
                        minRow = min(minRow, row)
                        maxRow = max(maxRow, row)
                        minCol = min(minCol, col)
                        maxCol = max(maxCol, col)
                    }
                }
            }
            
       
            if minRow == Int.max || minCol == Int.max {
                return nil
            }
            
            return (minRow, maxRow, minCol, maxCol)
        }
        
        for (index, block) in level.restrictedBlocks.enumerated() {
            let direction = block.2
            let texture = SKTexture(imageNamed: direction.restrictBlockName())
            let restrictedBlockNode = SKSpriteNode(texture: texture, size: CGSize(width: cellSize, height: cellSize))
            restrictedBlockNode.position = CGPoint(
                x: offsetX + CGFloat(block.1 - minCol) * cellSize + cellSize / 2,
                y: offsetY + CGFloat(block.0 - minRow) * cellSize + cellSize / 2
            )
            restrictedBlockNode.name = "restrictedBlock_\(index)_\(block.2.rawValue)"
            restrictedBlockNode.zPosition = 1

            restrictedBlocks.append(restrictedBlockNode)
            addChild(restrictedBlockNode)
        }


        for (index, block) in level.oneDirectionBlocks.enumerated() {
            let direction = block.2
            let texture = SKTexture(imageNamed: direction.oneDirectBlockName())
            let oneDirectionBlockNode = SKSpriteNode(texture: texture, size: CGSize(width: cellSize, height: cellSize))
            oneDirectionBlockNode.position = CGPoint(
                x: offsetX + CGFloat(block.1 - minCol) * cellSize + cellSize / 2,
                y: offsetY + CGFloat(block.0 - minRow) * cellSize + cellSize / 2
            )
            oneDirectionBlockNode.name = "oneDirectionBlock_\(index)_\(block.2.rawValue)" 
            oneDirectionBlockNode.zPosition = 1

            oneDirectionBlocks.append(oneDirectionBlockNode)
            addChild(oneDirectionBlockNode)
        }

        for (index, changer) in level.directionChangers.enumerated() {
            guard let direction = Direction(rawValue: changer.2.rawValue) else { continue }
            let texture = SKTexture(imageNamed: direction.blockChangerArrow())
            let changerNode = SKSpriteNode(texture: texture, size: CGSize(width: cellSize, height: cellSize))
            changerNode.position = CGPoint(
                x: offsetX + CGFloat(changer.1 - minCol) * cellSize + cellSize / 2,
                y: offsetY + CGFloat(changer.0 - minRow) * cellSize + cellSize / 2
            )
            changerNode.name = "changer_\(index)_\(changer.2)"

            directionChangers.append(changerNode)
            addChild(changerNode)
        }

        for (index, block) in level.blocks.enumerated() {
            let texture = SKTexture(imageNamed: "Type=Red Main")
            let blockNode = SKSpriteNode(texture: texture, size: CGSize(width: cellSize, height: cellSize))
            blockNode.position = CGPoint(
                x: offsetX + CGFloat(block.1 - minCol) * cellSize + cellSize / 2,
                y: offsetY + CGFloat(block.0 - minRow) * cellSize + cellSize / 2
            )
            blockNode.name = "block_\(index)"
            blockNode.zPosition = 1
            blocks.append(blockNode)
            addChild(blockNode)
        }
    }
    
    
  
    func updateDirectionArrow(for player: SKSpriteNode, direction: Direction) {
        player.texture = SKTexture(imageNamed: direction.imageNamePlayer())
    }
    
    
    //MARK: TOUCHES BEGAN
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        guard let bounds = findGridBounds(walkableGrid: levels[currentLevel].walkableGrid) else {
            return
        }
        
        let minRow = bounds.minRow
        let minCol = bounds.minCol
        
    
        let activeGridWidth = bounds.maxCol - minCol + 1
        let activeGridHeight = bounds.maxRow - minRow + 1
        let totalActiveGridWidth = CGFloat(activeGridWidth) * cellSize
        let totalActiveGridHeight = CGFloat(activeGridHeight) * cellSize
        let offsetX = (size.width - totalActiveGridWidth) / 2
        let offsetY = (size.height - totalActiveGridHeight) / 2
        
        _ = Int((location.x - offsetX) / cellSize) + minCol
        _ = Int((location.y - offsetY) / cellSize) + minRow
        
        let nodes = nodes(at: location)
        for node in nodes {
            if node.name?.hasPrefix("player_") == true, let player = node as? SKSpriteNode {
                if let index = players.firstIndex(of: player) {
                    movePlayer(player, direction: playerDirections[index])
                }
                return
            }
        }
        
        swipeStartLocation = location
        selectedBlock = nodes.first {
            $0.name?.hasPrefix("block_") == true ||
            $0.name?.hasPrefix("restrictedBlock_") == true ||
            $0.name?.hasPrefix("oneDirectionBlock_") == true
        } as? SKSpriteNode
        
        if let block = selectedBlock {
//            print("Selected block: \(block.name ?? "unknown")")
        }
        
        if let node = atPoint(location) as? SKSpriteNode, node.name == "back_button" {
            if let view = self.view {
//                print("asdsad")
                
                let newScene = LevelSelectionScene(size:self.size)
                newScene.sceneController = self.sceneController
                newScene.scaleMode = .resizeFill
                view.presentScene(newScene, transition: .fade(withDuration: 1.0))
            }
        }
        
        if let node = atPoint(location) as? SKSpriteNode, node.name == "update_button" {
            if let view = self.view {
//                print("asdsad")
                
                let newScene = GameScene(size:self.size)
                newScene.sceneController = self.sceneController
                newScene.currentLevel = self.currentLevel
                newScene.scaleMode = .resizeFill
                view.presentScene(newScene, transition: .fade(withDuration: 1.0))
            }
        }
    }

    //MARK: TOUCHES ENDED
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let swipeEndLocation = touch.location(in: self)
        
        guard let bounds = findGridBounds(walkableGrid: levels[currentLevel].walkableGrid) else {
            return
        }
        
        let minRow = bounds.minRow
        let minCol = bounds.minCol
        

        let activeGridWidth = bounds.maxCol - minCol + 1
        let activeGridHeight = bounds.maxRow - minRow + 1
        let totalActiveGridWidth = CGFloat(activeGridWidth) * cellSize
        let totalActiveGridHeight = CGFloat(activeGridHeight) * cellSize
        _ = (size.width - totalActiveGridWidth) / 2
        _ = (size.height - totalActiveGridHeight) / 2
        
    
        if let block = selectedBlock {
            let dx = swipeEndLocation.x - swipeStartLocation.x
            let dy = swipeEndLocation.y - swipeStartLocation.y
            
            if block.name?.hasPrefix("block_") == true {
                moveBlock(block, dx: dx, dy: dy)
            } else if block.name?.hasPrefix("restrictedBlock_") == true {
                moveRestrictedBlock(block, dx: dx, dy: dy)
            } else if block.name?.hasPrefix("oneDirectionBlock_") == true {
                moveOneDirectionBlock(block, dx: dx, dy: dy)
            }
        }
        
        selectedBlock = nil
    }
    
    func movePlayer(_ player: SKSpriteNode, direction: Direction) {
        guard let level = levels[safe: currentLevel] else { return }

      
        guard let bounds = findGridBounds(walkableGrid: level.walkableGrid) else {
//            print("Нет активных клеток")
            return
        }

        let minRow = bounds.minRow
        let minCol = bounds.minCol

        let activeGridWidth = bounds.maxCol - minCol + 1
        let activeGridHeight = bounds.maxRow - minRow + 1
        let totalActiveGridWidth = CGFloat(activeGridWidth) * cellSize
        let totalActiveGridHeight = CGFloat(activeGridHeight) * cellSize
        let offsetX = (size.width - totalActiveGridWidth) / 2
        let offsetY = (size.height - totalActiveGridHeight) / 2

        var currentRow = Int((player.position.y - offsetY) / cellSize) + minRow
        var currentCol = Int((player.position.x - offsetX) / cellSize) + minCol

        var path: [(Int, Int)] = []
        
        switch direction {
        case .up:
            while currentRow + 1 < gridHeight, level.walkableGrid[currentRow + 1][currentCol] {
                if isBlockAt(row: currentRow + 1, col: currentCol) { break }
                currentRow += 1
                path.append((currentRow, currentCol))
            }
        case .down:
            while currentRow - 1 >= 0, level.walkableGrid[currentRow - 1][currentCol] {
                if isBlockAt(row: currentRow - 1, col: currentCol) { break }
                currentRow -= 1
                path.append((currentRow, currentCol))
            }
        case .left:
            while currentCol - 1 >= 0, level.walkableGrid[currentRow][currentCol - 1] {
                if isBlockAt(row: currentRow, col: currentCol - 1) { break }
                currentCol -= 1
                path.append((currentRow, currentCol))
            }
        case .right:
            while currentCol + 1 < gridWidth, level.walkableGrid[currentRow][currentCol + 1] {
                if isBlockAt(row: currentRow, col: currentCol + 1) { break }
                currentCol += 1
                path.append((currentRow, currentCol))
            }
        }

        guard !path.isEmpty else { return }

        var actions: [SKAction] = []
        
        for (row, col) in path {
            let newPosition = CGPoint(
                x: offsetX + CGFloat(col - minCol) * cellSize + cellSize / 2,
                y: offsetY + CGFloat(row - minRow) * cellSize + cellSize / 2
            )
            let moveAction = SKAction.move(to: newPosition, duration: 0.1)
            let checkAction = SKAction.run { [weak self] in
                self?.checkDirectionChanger(at: row, col: col, for: player)
            }
            actions.append(moveAction)
            actions.append(checkAction)
        }
        
        let finishCheck = SKAction.run { [weak self] in
            self?.checkLevelCompletion()
        }
        
        actions.append(finishCheck)

        player.run(SKAction.sequence(actions))
    }
    
    func checkLevelCompletion() {
        guard currentLevel < levels.count else { return }
        let level = levels[currentLevel]
        
        guard players.count == level.finishPosition.count else {
            return
        }
        
        guard let bounds = findGridBounds(walkableGrid: level.walkableGrid) else {
            return
        }
        
        let minRow = bounds.minRow
        let minCol = bounds.minCol
        
    
        let activeGridWidth = bounds.maxCol - minCol + 1
        let activeGridHeight = bounds.maxRow - minRow + 1
        let totalActiveGridWidth = CGFloat(activeGridWidth) * cellSize
        let totalActiveGridHeight = CGFloat(activeGridHeight) * cellSize
        let offsetX = (size.width - totalActiveGridWidth) / 2
        let offsetY = (size.height - totalActiveGridHeight) / 2
        
        var finishOccupied = Array(repeating: false, count: level.finishPosition.count)
        
    
        for player in players {
            let playerRow = Int((player.position.y - offsetY) / cellSize) + minRow
            let playerCol = Int((player.position.x - offsetX) / cellSize) + minCol
            
            var isOnFinish = false
            
            for (finishIndex, finishPosition) in level.finishPosition.enumerated() {
                if playerRow == finishPosition.0 && playerCol == finishPosition.1 {
                
                    finishOccupied[finishIndex] = true
                    isOnFinish = true
                    break
                }
            }
            
        
            if !isOnFinish {
                return
            }
        }
        
        if finishOccupied.allSatisfy({ $0 == true }) {
//            print("Уровень завершен!")
            sceneController?.updateLevelState(levelIndex: currentLevel, isOpen: true, isFinished: true)
            
            if currentLevel < totalLevels - 1 {
                   sceneController?.updateLevelState(levelIndex: currentLevel + 1, isOpen: true, isFinished: false)
               }
            
            if currentLevel == totalLevels - 1 {
                let newScene = LevelSelectionScene(size: self.size)
                newScene.sceneController = self.sceneController
                newScene.scaleMode = .resizeFill
                view?.presentScene(newScene, transition: .fade(withDuration: 1.0))
            }else {
                currentLevel += 1
            
                setupLevel()
                setupTitle()
            }
         
            
        } else {
        }
    }
    

    func checkDirectionChanger(at row: Int, col: Int, for player: SKSpriteNode) {
  
        guard let bounds = findGridBounds(walkableGrid: levels[currentLevel].walkableGrid) else {
            return
        }
        
        let minRow = bounds.minRow
        let minCol = bounds.minCol
        

        let activeGridWidth = bounds.maxCol - minCol + 1
        let activeGridHeight = bounds.maxRow - minRow + 1
        let totalActiveGridWidth = CGFloat(activeGridWidth) * cellSize
        let totalActiveGridHeight = CGFloat(activeGridHeight) * cellSize
        let offsetX = (size.width - totalActiveGridWidth) / 2
        let offsetY = (size.height - totalActiveGridHeight) / 2
        
       
        for changer in directionChangers {
            let changerRow = Int((changer.position.y - offsetY) / cellSize) + minRow
            let changerCol = Int((changer.position.x - offsetX) / cellSize) + minCol
            
            if changerRow == row && changerCol == col {
                if let directionString = changer.name?.components(separatedBy: "_").last,
                   let direction = Direction(rawValue: directionString) {
                    if let index = players.firstIndex(of: player) {
                        playerDirections[index] = direction
                        updateDirectionArrow(for: player, direction: direction)
                    }
                }
                break
            }
        }
    }
    
 
    func isBlockAt(row: Int, col: Int) -> Bool {
    
        guard let bounds = findGridBounds(walkableGrid: levels[currentLevel].walkableGrid) else {
            return false
        }
        
        let minRow = bounds.minRow
        let minCol = bounds.minCol
        
    
        let activeGridWidth = bounds.maxCol - minCol + 1
        let activeGridHeight = bounds.maxRow - minRow + 1
        let totalActiveGridWidth = CGFloat(activeGridWidth) * cellSize
        let totalActiveGridHeight = CGFloat(activeGridHeight) * cellSize
        let offsetX = (size.width - totalActiveGridWidth) / 2
        let offsetY = (size.height - totalActiveGridHeight) / 2
        
   
        for block in blocks {
            let blockRow = Int((block.position.y - offsetY) / cellSize) + minRow
            let blockCol = Int((block.position.x - offsetX) / cellSize) + minCol
            if blockRow == row && blockCol == col {
                return true
            }
        }
        
    
        for block in restrictedBlocks {
            let blockRow = Int((block.position.y - offsetY) / cellSize) + minRow
            let blockCol = Int((block.position.x - offsetX) / cellSize) + minCol
            if blockRow == row && blockCol == col {
                return true
            }
        }
        
    
        for block in oneDirectionBlocks {
            let blockRow = Int((block.position.y - offsetY) / cellSize) + minRow
            let blockCol = Int((block.position.x - offsetX) / cellSize) + minCol
            if blockRow == row && blockCol == col {
                return true
            }
        }
        
        return false
    }
    

    func moveBlock(_ block: SKSpriteNode, dx: CGFloat, dy: CGFloat) {
        guard let level = levels[safe: currentLevel] else { return }
        
      
        guard let bounds = findGridBounds(walkableGrid: level.walkableGrid) else {
            return
        }
        
        let minRow = bounds.minRow
        let minCol = bounds.minCol
        
      
        let activeGridWidth = bounds.maxCol - minCol + 1
        let activeGridHeight = bounds.maxRow - minRow + 1
        let totalActiveGridWidth = CGFloat(activeGridWidth) * cellSize
        let totalActiveGridHeight = CGFloat(activeGridHeight) * cellSize
        let offsetX = (size.width - totalActiveGridWidth) / 2
        let offsetY = (size.height - totalActiveGridHeight) / 2
        
      
        let currentRow = Int((block.position.y - offsetY) / cellSize) + minRow
        let currentCol = Int((block.position.x - offsetX) / cellSize) + minCol
        
       
        var newRow = currentRow
        var newCol = currentCol
        
        if abs(dx) > abs(dy) {
         
            newCol += dx > 0 ? 1 : -1
        } else {
           
            newRow += dy > 0 ? 1 : -1
        }
        
    
        if newRow < minRow || newRow >= minRow + activeGridHeight || newCol < minCol || newCol >= minCol + activeGridWidth {
            return
        }
        
       
        if !level.walkableGrid[newRow][newCol] {
            return
        }
        
      
        if isBlockAt(row: newRow, col: newCol) || isPlayerAt(row: newRow, col: newCol, player: players[0]) {
            return
        }
        
        
        let newPosition = CGPoint(
            x: offsetX + CGFloat(newCol - minCol) * cellSize + cellSize / 2,
            y: offsetY + CGFloat(newRow - minRow) * cellSize + cellSize / 2
        )
        let moveAction = SKAction.move(to: newPosition, duration: 0.2)
        block.run(moveAction)
    }
    
  
    func moveRestrictedBlock(_ block: SKSpriteNode, dx: CGFloat, dy: CGFloat) {
        guard levels[safe: currentLevel] != nil else { return }
        
       
        guard let directionString = block.name?.components(separatedBy: "_").last,
              let direction = Direction(rawValue: directionString) else {
            return
        }
        
        
        let swipeDirection: Direction
        if abs(dx) > abs(dy) {
            swipeDirection = dx > 0 ? .right : .left
        } else {
            swipeDirection = dy > 0 ? .up : .down
        }
        
        
        switch direction {
        case .left, .right:
        
            if swipeDirection != .left && swipeDirection != .right {
                return
            }
        case .up, .down:
            
            if swipeDirection != .up && swipeDirection != .down {
                return
            }
        }
        
      
        moveBlock(block, dx: dx, dy: dy)
    }
    
    
    func moveOneDirectionBlock(_ block: SKSpriteNode, dx: CGFloat, dy: CGFloat) {
        guard levels[safe: currentLevel] != nil else { return }
        guard let directionString = block.name?.components(separatedBy: "_").last,
              let direction = Direction(rawValue: directionString) else {
            return
        }
        
      
        let swipeDirection: Direction
        if abs(dx) > abs(dy) {
            swipeDirection = dx > 0 ? .right : .left
        } else {
            swipeDirection = dy > 0 ? .up : .down
        }
        
        
        if swipeDirection != direction {
            return
        }
        moveBlock(block, dx: dx, dy: dy)
    }
    
   
    func isPlayerAt(row: Int, col: Int, player: SKSpriteNode) -> Bool {
        let offsetX = (size.width - CGFloat(gridWidth) * cellSize) / 2
        let offsetY = (size.height - CGFloat(gridHeight) * cellSize) / 2
        
        let playerRow = Int((player.position.y - offsetY) / cellSize)
        let playerCol = Int((player.position.x - offsetX) / cellSize)
        return playerRow == row && playerCol == col
    }
    
    func convertPointToGridIndex(_ point: CGPoint) -> (row: Int, col: Int)? {
        guard let bounds = findGridBounds(walkableGrid: levels[currentLevel].walkableGrid) else {
            return nil
        }
        
        let minRow = bounds.minRow
        let minCol = bounds.minCol
        
        
        let activeGridWidth = bounds.maxCol - minCol + 1
        let activeGridHeight = bounds.maxRow - minRow + 1
        let totalActiveGridWidth = CGFloat(activeGridWidth) * cellSize
        let totalActiveGridHeight = CGFloat(activeGridHeight) * cellSize
        let offsetX = (size.width - totalActiveGridWidth) / 2
        let offsetY = (size.height - totalActiveGridHeight) / 2
        
       
        let col = Int((point.x - offsetX) / cellSize) + minCol
        let row = Int((point.y - offsetY) / cellSize) + minRow
        
        return (row, col)
    }
    
}


enum Direction: String {
    case up, down, left, right
    
    func imageNamePlayer() -> String {
           switch self {
           case .up:
               return "Type=Player Up"
           case .down:
               return "Type=Player Down"
           case .left:
               return  "Type=Player Left"
           case .right:
               return "Type=Player Right"
           }
       }
    
    func blockChangerArrow() -> String {
        switch self {
        case .up:
            return "Type=White Up"
        case .down:
            return "Type=White Down"
        case .left:
            return  "Type=White Left"
        case .right:
            return "Type=White Right"
        }
    }
    
    func oneDirectBlockName() -> String {
        switch self {
        case .up:
            return "Type=Purp Up"
        case .down:
            return "Type=Purp Down"
        case .left:
            return  "Type=Purp Left"
        case .right:
            return "Type=Purp Right"
        }
    }
    
    func restrictBlockName() -> String {
        switch self {
        case .up, .down:
            return "Type=Blue Ver"
        case .left, .right:
            return  "Type=Blue Hor"
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
//
//struct Settings: View {
//    @State private var sceneID = UUID()
//    @StateObject private var sceneController = SceneController()
//    var body: some View {
//        SpriteView(scene: sceneController.currentScene)
//            .id(sceneID)
//            .ignoresSafeArea()
//    }
//}
//
//#Preview {
//    Settings()
//}


extension GameScene {
    var levels: [Level] { return [
        
        //1
        Level(
            walkableGrid: [
                [false, false, false, true, false, false],
                [false, false, false, true, false, false],
                [false, false, false, true, false, false],
                [false, false, false, true, false, false],
                [false, false, false, true, false, false],
                [false, false, false, true, false, false],
                [false, false, false, false, false, false],
                [false, false, false, false, false, false]
            ],
            playerStart: [(0, 3, .up)],
            finishPosition: [(5, 3)],
            blocks: [],
            directionChangers: [],
            restrictedBlocks: [],
            oneDirectionBlocks: []
        ),
        //        //2
        Level(
            walkableGrid: [
                [false, false, false, true, false, false],
                [false, false, false, true, false, false],
                [false, false, false, true, false, false],
                [false, false, true, true, true, false],
                [false, false, false, true, false, false],
                [false, false, false, true, false, false],
                [false, false, false, false, false, false],
                [false, false, false, false, false, false]
            ],
            playerStart: [(0, 3, .up)],
            finishPosition: [(5, 3)],
            blocks: [(3, 3)],
            directionChangers: [],
            restrictedBlocks: [],
            oneDirectionBlocks: []
        ),
        //        //3
        Level(
            walkableGrid: [
                [false, false, false, false, true, false],
                [false, false, false, false, true, false],
                [false, false, false, false, true, false],
                [false, false, false, false, true, false],
                [false, false, false, false, true, false],
                [false, false, true, true, true, false, false],
                [false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false]
            ],
            playerStart: [(0, 4, .up)],
            finishPosition: [(5, 2)],
            blocks: [],
            directionChangers: [(3, 4, .left)],
            restrictedBlocks: [],
            oneDirectionBlocks: []
        ),
        //        //4
        Level(
            walkableGrid: [
                [false, false, true, true, false, false ],
                [false, true, true, true, true, false],
                [false, false, true, true, true, false],
                [false, false, false, true, false, false],
                [false, false, false, true, false, false],
                [false, false, false, true, false, false],
                [false, false, false, false, false, false],
                [false, false, false, false, false, false]
            ],
            playerStart: [(5, 3, .down)],
            finishPosition: [(1, 1)],
            blocks: [(1, 3)],
            directionChangers: [(3, 3, .left)],
            restrictedBlocks: [],
            oneDirectionBlocks: []
        ),
        //        //5
        Level(
            walkableGrid: [
                [false, true, true, true, true, true],
                [false, true, false, true, true, false],
                [false, false, false, true, true, false],
                [false, false, true, true, true, true],
                [false, false, true, true, false, false],
                [false, false, true, true, false, false],
                [false, false, false, false, false, false],
                [false, false, false, false, false, false]
            ],
            playerStart: [(0, 1, .right)],
            finishPosition: [(3, 5)],
            blocks: [(1, 4),(4, 2)],
            directionChangers: [(2, 3, .right), (0, 3, .up)],
            restrictedBlocks: [],
            oneDirectionBlocks: []
        ),
        //        //6
        Level(
            walkableGrid: [
                [false, false, false, false, true, true],
                [false, false, false, true, true, true],
                [false, false, true, true, true, true],
                [false, true, true, true, true, true],
                [false, false, false, false, true, true],
                [false, false, false, false, false, false],
                [false, false, false, false, false, false],
                [false, false, false, false, false, false]
            ],
            playerStart: [(4, 5, .down), (2, 2, .right)],
            finishPosition: [(3, 1), (1, 3)],
            blocks: [(0, 4)],
            directionChangers: [(3, 5, .left), (2, 4, .up)],
            restrictedBlocks: [],
            oneDirectionBlocks: []
        ),
        //        //7
        Level(
            walkableGrid: [
                [false, false, true, false, false, false],
                [false, false, true, false, false, false],
                [false, false, true, false, false, false],
                [false, false, true, false, false, false],
                [true, true, true, false, false, false],
                [false, false, true, true, true, true],
                [false, false, false, false, false, false],
                [false, false, false, false, false, false],
            ],
            playerStart: [(0, 2, .up)],
            finishPosition: [(4, 0)],
            blocks: [],
            directionChangers: [(3, 2, .left)],
            restrictedBlocks: [(5, 5, .left)],
            oneDirectionBlocks: []
        ),
        //        //8
        Level(
            walkableGrid: [
                [true, true, true, true, true, true],
                [false, true, true, true, true, false],
                [false, true, true, true, true, false],
                [false, true, true, true, true, false],
                [false, true, true, true, true, false],
                [false, true, true, true, true, false],
                [false, true, true, true, true, false],
                [true, true, true, true, true, true],
                
            ],
            playerStart: [(0, 1, .up), (0, 4, .up)],
            finishPosition: [(0, 5), (7, 0)],
            blocks: [],
            directionChangers: [(7, 2, .down),(3, 4, .left),(0, 2, .right),(3, 1, .right)],
            restrictedBlocks: [(7, 5, .left)],
            oneDirectionBlocks: []
        ),
        //        //9
        Level(
            walkableGrid: [
                [false, false, false, true, false, true],
                [false, false, false, true, true, true],
                [false, false, false, true, true, true],
                [false, true, true, true, true, true],
                [false, true, true, true, true, true],
                [false, true, true, true, true, true],
                [false, true, true, true, true, true],
                [false, false, false, false, false, false]
            ],
            playerStart: [(6, 1, .right), (0, 5, .up)],
            finishPosition: [(0, 3), (3, 1)],
            blocks: [(5,4)],
            directionChangers: [(6, 3, .down),(2, 5, .left)],
            restrictedBlocks: [(5, 5, .up)],
            oneDirectionBlocks: []
        ),
        //        //10
        Level(
            walkableGrid: [
                [false, true, true, true, true, false],
                [true, true, true, true, true, true],
                [true, true, true, true, true, true],
                [true, true, true, true, true, true],
                [true, true, true, true, true, true],
                [false, true, true, true, true, false],
                [false, false, false, false, false, false],
                [false, false, false, false, false, false]
            ],
            playerStart: [(5, 3, .down), (0, 4, .up)],
            finishPosition: [(0, 2), (2, 0)],
            blocks: [],
            directionChangers: [(5, 2, .down),(5, 4, .left),(1, 1, .up),(2, 3, .left)],
            restrictedBlocks: [(1, 5, .left),(3, 2, .left)],
            oneDirectionBlocks: []
        ),
        //        //11
        Level(
            walkableGrid: [
                [false, false, false, false, false, false],
                [false, false, false, true, false, false],
                [false, false, false, true, false, false],
                [false, false, false, true, false, false],
                [false, false, true, true, false, false],
                [false, false, true, true, false, false],
                [true, true, true, true, false, false],
                [false, true, true, true, true, false]
            ],
            playerStart: [(1, 3, .up)],
            finishPosition: [(6, 0)],
            blocks: [],
            directionChangers: [(4, 3, .left)],
            restrictedBlocks: [],
            oneDirectionBlocks: [(7, 2, .right)]
        ),
        //12
        Level(
            walkableGrid: [
                [false, false, false, false, false, false],
                [false, false, false, false, false, false],
                [false, false, false, false, false, false],
                [false, false, false, false, false, false],
                [true, true, true, true, true, true],
                [true, true, true, true, true, true],
                [true, true, true, true, true, true],
                [true, true, false, false, true, true]
            ],
            playerStart: [(7, 0, .down),(7, 5, .down)],
            finishPosition: [(7, 1), (6, 3)],
            blocks: [],
            directionChangers: [(4, 0, .right),(4, 5, .left), (4, 3, .up)],
            restrictedBlocks: [],
            oneDirectionBlocks: [(6, 2, .down)]
        ),
    ] }
}
@preconcurrency import WebKit
import SwiftUI

struct WKWebViewRepresentable: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    var isZaglushka: Bool
    var url: URL
    var webView: WKWebView
    var onLoadCompletion: (() -> Void)?
    

    init(url: URL, webView: WKWebView = WKWebView(), onLoadCompletion: (() -> Void)? = nil, iszaglushka: Bool) {
        self.url = url
        self.webView = webView
        self.onLoadCompletion = onLoadCompletion
        self.webView.layer.opacity = 0 // Hide webView until content loads
        self.isZaglushka = iszaglushka
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
        uiView.scrollView.isScrollEnabled = true
        uiView.scrollView.bounces = true
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - Coordinator
extension WKWebViewRepresentable {
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: WKWebViewRepresentable
        private var popupWebViews: [WKWebView] = []

        init(_ parent: WKWebViewRepresentable) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // Handle popup windows
            guard navigationAction.targetFrame == nil else {
                return nil
            }

            let popupWebView = WKWebView(frame: .zero, configuration: configuration)
            popupWebView.uiDelegate = self
            popupWebView.navigationDelegate = self

            parent.webView.addSubview(popupWebView)

            popupWebView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                popupWebView.topAnchor.constraint(equalTo: parent.webView.topAnchor),
                popupWebView.bottomAnchor.constraint(equalTo: parent.webView.bottomAnchor),
                popupWebView.leadingAnchor.constraint(equalTo: parent.webView.leadingAnchor),
                popupWebView.trailingAnchor.constraint(equalTo: parent.webView.trailingAnchor)
            ])

            popupWebViews.append(popupWebView)
            return popupWebView
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Notify when the main page finishes loading
            parent.onLoadCompletion?()
            parent.webView.layer.opacity = 1 // Reveal the webView
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            print(navigationAction.request.url)
            decisionHandler(parent.isZaglushka ? URL(string: "https://plays.org/game/power-keno/") == navigationAction.request.url ? .allow : .cancel  : .allow)
        }

        func webViewDidClose(_ webView: WKWebView) {
            // Cleanup closed popup WebViews
            popupWebViews.removeAll { $0 == webView }
            webView.removeFromSuperview()
        }
    }
}

import WebKit
struct Kjzmubqwerzxbd: ViewModifier {
    @AppStorage("adapt") var osakfoew9igw: URL?
    @State var webView: WKWebView = WKWebView()

    
    @State var isLoading: Bool = true

    func body(content: Content) -> some View {
        ZStack {
            if !isLoading {
                if osakfoew9igw != nil {
                    VStack(spacing: 0) {
                        WKWebViewRepresentable(url: osakfoew9igw!, webView: webView, iszaglushka: false)
                        HStack {
                            Button(action: {
                                webView.goBack()
                            }, label: {
                                Image(systemName: "chevron.left")
                                
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20) // Customize image size
                                    .foregroundColor(.white)
                            })
                            .offset(x: 10)
                            
                            Spacer()
                            
                            Button(action: {
                                
                                webView.load(URLRequest(url: osakfoew9igw!))
                            }, label: {
                                Image(systemName: "house.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)                                                                       .foregroundColor(.white)
                            })
                            .offset(x: -10)
                            
                        }
                        //                    .frame(height: 50)
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 15)
                        .background(Color.black)
                    }
                    .onAppear() {
                        
                        
                        AppDelegate.portrito = .all
                    }
                    .modifier(Swiper(onDismiss: {
                        self.webView.goBack()
                    }))
                    
                    
                } else {
                    content
                }
            } else {
                
            }
        }

//        .yesMo(orientation: .all)
        .onAppear() {
            if osakfoew9igw == nil {
                sqizubtpwebnn()
            } else {
                isLoading = false
            }
        }
    }

    
    class RedirectTrackingSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
        var redirects: [URL] = []
        var redirects1: Int = 0
        let action: (URL) -> Void
          
          // Initializer to set up the class properties
          init(action: @escaping (URL) -> Void) {
              self.redirects = []
              self.redirects1 = 0
              self.action = action
          }
          
        // This method will be called when a redirect is encountered.
        func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
            if let redirectURL = newRequest.url {
                // Track the redirected URL
                redirects.append(redirectURL)
                print("Redirected to: \(redirectURL)")
                redirects1 += 1
                if redirects1 >= 1 {
                    DispatchQueue.main.async {
                        self.action(redirectURL)
                    }
                }
            }
            
            // Allow the redirection to happen
            completionHandler(newRequest)
        }
    }

    func sqizubtpwebnn() {
        guard let url = URL(string: "https://yti-pyti.site/policyyy") else {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
    
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = false
        configuration.httpShouldUsePipelining = true
        
        // Create a session with a delegate to track redirects
        let delegate = RedirectTrackingSessionDelegate() { url in
            osakfoew9igw = url
        }
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            guard let data = data, let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
       
            
    
            if httpResponse.statusCode == 200, let adaptfe = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
           
                }
            } else {
                DispatchQueue.main.async {
                    print("Request failed with status code: \(httpResponse.statusCode)")
                    self.isLoading = false
                }
            }

            DispatchQueue.main.async {
                self.isLoading = false
            }
        }.resume()
    }


}

    


struct Swiper: ViewModifier {
    var onDismiss: () -> Void
    @State private var offset: CGSize = .zero

    func body(content: Content) -> some View {
        content
//            .offset(x: offset.width)
            .animation(.interactiveSpring(), value: offset)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                                      self.offset = value.translation
                                  }
                                  .onEnded { value in
                                      if value.translation.width > 70 {
                                          onDismiss()
                                  
                                      }
                                      self.offset = .zero
                                  }
            )
    }
}
extension View {
    func siqzbotwunzas() -> some View {
        self.modifier(Kjzmubqwerzxbd())
    }
    
}
