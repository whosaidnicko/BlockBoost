import SpriteKit
import StoreKit

final class SettingsScene: SKScene {
    
    let openPage = OpenPage()
    var sceneController: SceneController?
    private var loadingSpinner: SKSpriteNode?
    private var background: SKSpriteNode!
    private var titleLabel: SKLabelNode!
    private var backButton: SKSpriteNode!
    private var buttonNames = ["privacyBtn", "shareBtn", "rateBtn"]

    //MARK: Did Move
    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        
        setupBackground()
        setupTitle()
        setupBackButton()
        setupButtons()
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

        titleLabel = SKLabelNode(text: "Settings")
        titleLabel.fontName = "Montserrat-Bold"
        titleLabel.fontSize = 24
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - titleLabel.fontSize * 3.2  - offsetY)

        addChild(titleLabel)
    }

    //MARK: Back Button (Arrow)
    private func setupBackButton() {
      
        backButton = createButton(named: "backButton", size: CGSize(width: 14, height: 21), position: CGPoint(x: 50, y: titleLabel.position.y + 10), name: "back_button")
        addChild(backButton)
    }

    //MARK: Setup Buttons
    private func setupButtons() {
        let offsetY: CGFloat = size.height > 850 ? 20 : 40
       
        let verticalSpacing: CGFloat = -85
        let startY: CGFloat = size.height / 1.25

        for (index, buttonName) in buttonNames.enumerated() {
            let buttonPosition = CGPoint(x: size.width / 2, y: startY + CGFloat(index) * verticalSpacing - offsetY)
            let button = createButton(named: buttonName, size: CGSize(width: 326, height: 72), position: buttonPosition, name: buttonName)
            addChild(button)
        }
    }

    //MARK: Image Button Creation
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

        if let node = atPoint(location) as? SKSpriteNode {
            handleButtonClick(node: node)
        }
    }

    //MARK: Action for Button Click
    private func handleButtonClick(node: SKSpriteNode) {
        guard let name = node.name else { return }

        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        node.run(sequence)

    
        switch name {
        case "back_button":
            
            let newScene = MainMenuScene(size:self.size)
            newScene.sceneController = self.sceneController
            newScene.scaleMode = .resizeFill
            view?.presentScene(newScene, transition: .fade(withDuration: 1.0))
        case "privacyBtn":
            openPage.openWebView()

        case "shareBtn":
            shareApp()
            
        case "rateBtn":
            rateApp()
        default:
            break
        }
    }
    
 
    
    //MARK: Convert Hex Color to SKColor
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
    }
}



//import SwiftUI
//import SpriteKit
//
//struct SettingsView: View {
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
//                if let mainMenuScene = sceneController.currentScene as? SettingsScene {
//                    mainMenuScene.sceneController = sceneController
//                }
//            }
//    
//    }
//}
//
//
//
//#Preview {
//    SettingsView()
//}


extension SettingsScene {
    
    func shareApp() {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.yourcompany.yourapp"
        let appStoreLink = "https://apps.apple.com/app/\(bundleIdentifier)"
        let activityViewController = UIActivityViewController(activityItems: [appStoreLink], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func rateApp() {
           showLoadingSpinner()
           if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
               SKStoreReviewController.requestReview(in: scene)
           }
           hideLoadingSpinner()
       }

    private func showLoadingSpinner() {
    
          let symbolImage = UIImage(systemName: "hourglass.bottomhalf.filled")
          let texture = SKTexture(image: symbolImage!)


          loadingSpinner = SKSpriteNode(texture: texture)
          loadingSpinner?.size = CGSize(width: 30, height: 50)
          loadingSpinner?.position = CGPoint(x: size.width / 2, y: size.height / 2)
          addChild(loadingSpinner!)


          let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 1)
          let repeatAction = SKAction.repeatForever(rotateAction)
          loadingSpinner?.run(repeatAction)
      }

       private func hideLoadingSpinner() {
          
           let delayAction = SKAction.wait(forDuration: 1)
           let removeAction = SKAction.removeFromParent()
           loadingSpinner?.run(SKAction.sequence([delayAction, removeAction]))
       }
    
    
}



