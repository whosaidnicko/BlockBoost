import SwiftUI
import SpriteKit
import StoreKit

class SceneController: ObservableObject {
    
    @Published var currentScene: SKScene
    private var levelStates: [LevelState]
    
    
    init() {
  
      
      
        self.levelStates = []
        self.currentScene = MainMenuScene(size: CGSize(width: 400, height: 800))
        //        self.currentScene = SettingsScene(size: CGSize(width: 400, height: 800))
//                self.currentScene = GameScene(size: CGSize(width: 400, height: 800))
//        self.currentScene = LevelSelectionScene(size: CGSize(width: 400, height: 800))
        self.currentScene.scaleMode = .resizeFill
    
        self.levelStates = self.loadLevelStates()
        
    }
    
    func loadLevelStates() -> [LevelState] {
            if let savedData = UserDefaults.standard.data(forKey: "levelStates") {
                let decoder = JSONDecoder()
                if let decodedStates = try? decoder.decode([LevelState].self, from: savedData) {
                    return decodedStates
                }
            }
            
            return self.initializeLevelStates()
        }
    
    func saveLevelStates() {
           let encoder = JSONEncoder()
           if let encoded = try? encoder.encode(levelStates) {
               UserDefaults.standard.set(encoded, forKey: "levelStates")
           }
       }
  
    func initializeLevelStates() -> [LevelState] {
        var levelStates: [LevelState] = []
        
        for levelIndex in 0..<12 {
            let state = LevelState(levelIndex: levelIndex, isOpen: levelIndex == 0, isFinished: true)
            levelStates.append(state)
        }
        
        return levelStates
    }
    
    func getLevelState(for levelIndex: Int) -> LevelState? {
        return levelStates.first { $0.levelIndex == levelIndex }
    }
    
    func updateLevelState(levelIndex: Int, isOpen: Bool, isFinished: Bool) {
        if let index = levelStates.firstIndex(where: { $0.levelIndex == levelIndex }) {
            levelStates[index].isOpen = isOpen
            levelStates[index].isFinished = isFinished
            saveLevelStates()
        }
    }
    
    func getAllLevelStates() -> [LevelState] {
        return levelStates
    }

}



