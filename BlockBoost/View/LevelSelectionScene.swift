import SwiftUI
import SpriteKit



class LevelSelectionScene: SKScene {
    
    var sceneController: SceneController?
    
    private var levelButtons: [SKSpriteNode] = []
    private var titleLabel: SKLabelNode!
    private var background: SKSpriteNode!
    
    var buttonWidth: CGFloat = 155
    var buttonHeight: CGFloat = 92
    let levelsPerRow: Int = 2
    let totalLevels: Int = 12
    private var backButton: SKSpriteNode!
    override func didMove(to view: SKView) {
        setupBackground()
        adjustButtonSize(for: view)
        createLevelButtons()
        setupTitle()
      
    }
    
    
    private func adjustButtonSize(for view: SKView) {
//           let screenWidth = view.bounds.width
           let screenWidth = view.bounds.height
        
           if screenWidth < 750 {
               buttonWidth = 120
               buttonHeight = 70
           } else if screenWidth < 850 {
               buttonWidth = 130
               buttonHeight = 80
           }
       }
    
    private func setupBackground() {
        background = SKSpriteNode(imageNamed: "bg")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: size.width, height: size.height)
        addChild(background)
    }
    
    //MARK: Title "Settings"
    private func setupTitle() {
        let offsetY: CGFloat = size.height > 850 ? 20 : 0

        titleLabel = SKLabelNode(text: "Choose the Level")
        titleLabel.fontName = "Montserrat-Bold"
        titleLabel.fontSize = 24
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - titleLabel.fontSize * 3.2  - offsetY)

        addChild(titleLabel)
        setupBackButton()
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
    
    private func createLevelButtons() {
        let buttonSpacing: CGFloat = 20
        let totalWidth = CGFloat(levelsPerRow) * buttonWidth + CGFloat(levelsPerRow - 1) * buttonSpacing
        let startX: CGFloat = (self.size.width - totalWidth) / 2
        let totalRows = (totalLevels + levelsPerRow - 1) / levelsPerRow
        let totalHeight = CGFloat(totalRows) * buttonHeight + CGFloat(totalRows - 1) * buttonSpacing
        let startY: CGFloat = (self.size.height + totalHeight) / 2 - buttonHeight
        
        for levelIndex in 0..<totalLevels {
            let row = levelIndex / levelsPerRow
            let col = levelIndex % levelsPerRow
            
          
            let button = SKSpriteNode(texture: SKTexture(imageNamed: "ButtonForLvl"))
            button.size = CGSize(width: buttonWidth, height: buttonHeight)
            button.position = CGPoint(
                x: startX + CGFloat(col) * (buttonWidth + buttonSpacing) + buttonWidth / 2,
                y: startY - CGFloat(row) * (buttonHeight + buttonSpacing)
            )
            button.name = "levelButton_\(levelIndex)"
            
          
            let label = SKLabelNode(text: "\(levelIndex + 1)")
            label.fontName = "Montserrat-Bold"
            label.fontSize = 24
            label.fontColor = .white
            label.position = CGPoint(x: 0, y: -8 )
            button.addChild(label)
            
           
            if let levelState = sceneController?.getLevelState(for: levelIndex), levelState.isOpen {
                button.alpha = 1.0
            } else {
                button.alpha = 0.5
            }
            
            levelButtons.append(button)
            addChild(button)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)

        for button in levelButtons {
            if button.contains(touchLocation) {
                if let nodeName = button.name, nodeName.hasPrefix("levelButton_") {
                   
                    let levelIndex = Int(nodeName.split(separator: "_")[1])!
                    
                    if let levelState = sceneController?.getLevelState(for: levelIndex), levelState.isOpen {
                      
                        let gameScene = GameScene(size: self.size)
                        gameScene.sceneController = self.sceneController
                        gameScene.currentLevel = levelIndex
                        gameScene.scaleMode = .resizeFill
                        
                        self.view?.presentScene(gameScene, transition: .fade(withDuration: 1.0))
                    }
                }
            }
        }
        
        if let node = atPoint(touchLocation) as? SKSpriteNode, node.name == "back_button" {
            if let view = self.view {
//                print("asdsad")
                
                let newScene = MainMenuScene(size:self.size)
                newScene.sceneController = self.sceneController
                newScene.scaleMode = .resizeFill
                view.presentScene(newScene, transition: .fade(withDuration: 1.0))
            }
        }
    }
}

//struct Settingss: View {
//    @State private var sceneID = UUID()
//    @StateObject private var sceneController = SceneController()
//    
//    var body: some View {
//        SpriteView(scene: sceneController.currentScene)
//            .id(sceneID)
//            .ignoresSafeArea()
//            .onAppear {
//                if let levelSelectionScene = sceneController.currentScene as? LevelSelectionScene {
//                    levelSelectionScene.sceneController = sceneController
//                } else {
// 
//                }
//            }
//         
//    }
//}
//
//#Preview {
//    Settingss()
//}
