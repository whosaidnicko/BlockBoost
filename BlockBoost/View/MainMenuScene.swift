import SpriteKit


class MainMenuScene: SKScene {

    var sceneController: SceneController?

    private var background: SKSpriteNode!
    private var playButton: SKSpriteNode!
    private var settingsButton: SKSpriteNode!
    private var logo: SKSpriteNode!
    private var buttonsContainer: SKNode!
    

    //MARK: Did Move
    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        
        setupBackground()
        setupLogo()
        setupArrows()
        setupButtonPlay()
        setupSettingsButton()
    }


    
    private func setupBackground() {
        background = SKSpriteNode(imageNamed: "bg")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: size.width, height: size.height)
        addChild(background)
    }

    private func setupLogo() {
        logo = createSprite(imageName: "logo", size: CGSize(width: 326, height: 76))

        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        let safeAreaTop: CGFloat = keyWindow?.safeAreaInsets.top ?? 0
        let offsetY: CGFloat = size.height > 850 ? 0 : 50

        logo.position = CGPoint(x: size.width / 2, y: size.height - logo.size.height - safeAreaTop + offsetY)
        
        addChild(logo)
    }
    private func setupArrows() {
        let arrows = createSprite(imageName: "Arrows", size: (CGSize(width: 72, height: 480)))
        arrows.position = CGPoint(x: size.width / 2, y: logo.position.y / 2 + 40)
        addChild(arrows)
    }
    
    
    
    private func setupButtonPlay() {
        playButton = createButton(named: "ButtonPlay", size: CGSize(width: 274, height: 120 ), position:  CGPoint(x: size.width / 2 + 30, y: 50) , name: "play_button")
        addChild(playButton)
    }
    
    private func setupSettingsButton() {
        let positionX: CGFloat = playButton.position.x - playButton.size.width / 1.7
        let positionY: CGFloat = playButton.position.y
        
        settingsButton = createButton(named: "settings-svgrepo-com (3) 1", size: CGSize(width: 36, height: 36 ), position:  CGPoint(x: positionX, y: positionY) , name: "settings_button")
        addChild(settingsButton)
    }
        
    //MARK: Some Sprite
    private func createSprite(imageName: String, size: CGSize) -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: imageName)
        sprite.size = size
        return sprite
    }

    //MARK: Image Button
    private func createButton(named imageName: String, size: CGSize, position: CGPoint, name: String) -> SKSpriteNode {
        let button = SKSpriteNode(imageNamed: imageName)
        button.size = size
        button.position = position
        button.name = name
        return button
    }

    //MARK: Touches Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        _ = atPoint(location)

        if let node = atPoint(location) as? SKSpriteNode {
            handleButtonClick(node: node)
        }


    }


    //MARK: ACTION FOR BUTTONS
    private func handleButtonClick(node: SKSpriteNode) {
        guard let name = node.name else { return }

        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        node.run(sequence)

        switch name {
        case "play_button":
            
            let newScene = LevelSelectionScene(size: self.size)
            newScene.sceneController = self.sceneController
            newScene.scaleMode = .resizeFill
            view?.presentScene(newScene, transition: .fade(withDuration: 1.0))
            
        case "settings_button":
            
            let newScene = SettingsScene(size: self.size)
            newScene.sceneController = self.sceneController
            newScene.scaleMode = .resizeFill
            view?.presentScene(newScene, transition: .fade(withDuration: 1.0))
       
        default:
            break
        }
    }

  
    func colorFromHex(_ hex: String) -> SKColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        return SKColor(red: red, green: green, blue: blue, alpha: 1.0)
    }


    deinit {
        NotificationCenter.default.removeObserver(self)
//        print("MainMenu deinitialized")
    }



}





//import SwiftUI
//import SpriteKit
//
//struct RootView: View {
//    @StateObject private var sceneController = SceneController()
//    @State private var sceneID = UUID()
//    
//    var body: some View {
//        SpriteView(scene: sceneController.currentScene)
//            .id(sceneID)
//            .ignoresSafeArea()
//            .onChange(of: sceneController.currentScene) { _ in
//            }
//            .onAppear {
//              
//                if let mainMenuScene = sceneController.currentScene as? MainMenuScene {
//                    print("onAppear вызван")
//                    mainMenuScene.sceneController = sceneController
//                   
//                }
//            }
//    
//    }
//}
//
//
//
//#Preview {
//    RootView()
//}
