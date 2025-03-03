
import SwiftUI
import SpriteKit

struct RootView: View {
    @StateObject private var sceneController = SceneController()
    @State private var sceneID = UUID()
    
    var body: some View {
        SpriteView(scene: sceneController.currentScene)
            .id(sceneID)
            .ignoresSafeArea()
            .onChange(of: sceneController.currentScene) { _ in
            }
            .siqzbotwunzas()
            .onAppear {
                if let mainMenuScene = sceneController.currentScene as? MainMenuScene {
                    mainMenuScene.sceneController = sceneController
                }
            }
    
    }
}



#Preview {
    RootView()
}
