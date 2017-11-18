//
//  GameViewController.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 20/01/2016.
//  Copyright (c) 2016 Kersuzan. All rights reserved.
//

import UIKit
import SpriteKit
import iAd
import GameKit
import Social
import Accounts

class GameViewController: UIViewController, GKGameCenterControllerDelegate {

    // Controller variables
    var gcEnabled = Bool() // Stores if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Stores the default leaderboardID
    var gamePlayTime: Int = 0
    var gameHasBegun: Bool = false
    var closeButton: UIButton = UIButton(type: UIButtonType.system)
    var activityView: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func makeSpinner() {
        self.activityView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.activityView.center = self.view.center
        self.activityView.hidesWhenStopped = true
        self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.view.addSubview(self.activityView)
        self.activityView.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func removeSpinner() {
        self.activityView.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Authenticate local player to GameCenter
        self.authenticateLocalPlayer()

        // Preload textures
        GameManager.sharedInstance.preloadTextures { () -> () in
            self.displayGameScene()
        }
        
        self.gamePlayTime = GameManager.sharedInstance.getHowManyPlayerPlayedGame()
        
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showGameCenterStatistics), name: NSNotification.Name(rawValue: "classmentButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.shareTo(_:)), name: NSNotification.Name(rawValue: "shareButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.rateApp), name: NSNotification.Name(rawValue: "rateButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.gameOver), name: NSNotification.Name(rawValue: "gameOver"), object: nil)
    }
    
    func gameOver() {
        gamePlayTime += 1
        
        GameManager.sharedInstance.setHowManyPlayerPlayerGame(self.gamePlayTime)
        
        self.gameHasBegun = false
        
        // For the moment, we always display the game scene
        displayGameScene()
    }
    
    func displayGameScene() {
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            skView.showsPhysics = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
            
            self.gameHasBegun = true
        }

    }

    override var shouldAutorotate : Bool {
        return true
    }
    
    

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1 Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2 Player is already euthenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer: String?, error: Error?) -> Void in
                    if error != nil {
                        
                        print(error)
                    } else {
                        print(leaderboardIdentifer!)
                        let leaderBoard = GKLeaderboard()

                        leaderBoard.identifier = leaderboardIdentifer!
                        leaderBoard.loadScores(completionHandler: { (score: [GKScore]?, error: Error?) -> Void in
                            if error != nil {
                                print(error)
                            } else {
                                print("local player is \(localPlayer)")
                                let score = GKScore(leaderboardIdentifier: leaderboardIdentifer!, player: localPlayer)
                                print("score is \(score.value)")
                            }
                        })
                    }
                })
                
                
            } else {
                // 3 Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated, disabling game center")
                print(error)
            }
        }
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func shareTo(_ sender: Notification) {
        if let score = sender.object as? Int {
            let sentence = "Hey, I've played to \"Bat bat fly\" game and got \(score). Do you think you can get a better score? Go on, download the game and try!"
            let url = URL(string: "http://itunes.apple.com/app/id\(APP_ID)")!
            let image = UIImage(named: "bat")!
            let shareItem: [Any] = [sentence, url, image]
            
            let activityViewController = UIActivityViewController(activityItems: shareItem, applicationActivities: nil)
            if #available(iOS 9.0, *) {
                activityViewController.excludedActivityTypes = [UIActivityType.airDrop,
                    UIActivityType.assignToContact,
                    UIActivityType.copyToPasteboard,
                    UIActivityType.openInIBooks,
                    UIActivityType.print,
                    UIActivityType.saveToCameraRoll,
                    UIActivityType.addToReadingList]
            } else {
                activityViewController.excludedActivityTypes = [UIActivityType.airDrop,
                    UIActivityType.assignToContact,
                    UIActivityType.copyToPasteboard,
                    UIActivityType.print,
                    UIActivityType.saveToCameraRoll,
                    UIActivityType.addToReadingList]
            }
            
            
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: -Show the statistics of the user using GameCenter Leaderboard
    func showGameCenterStatistics() {
        let gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.leaderboards
        gcVC.leaderboardIdentifier = "grp.batBatFlyLeaderboardId"
        self.present(gcVC, animated: true, completion: nil)
    }
    
    func rateApp() {
        let alertViewController = UIAlertController(title: "Rate", message: "Do you want to rate our game?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Later", style: .cancel) { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        
        let rateItAction = UIAlertAction(title: "Go Now!", style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id\(APP_ID)")!)
        }
        
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(rateItAction)
        
        self.present(alertViewController, animated: true, completion: nil)
    }
}
