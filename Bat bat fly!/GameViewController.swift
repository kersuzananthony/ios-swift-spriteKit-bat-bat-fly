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

class GameViewController: UIViewController, ADBannerViewDelegate, GKGameCenterControllerDelegate {

    
    var gcEnabled = Bool() // Stores if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Stores the default leaderboardID
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let screenRect = UIScreen.mainScreen().bounds
        let adView = ADBannerView(frame: CGRectZero)
        adView.frame = CGRectMake(0, 0, screenRect.size.width, adView.frame.size.height)
        adView.delegate = self
        self.view.addSubview(adView)

    }
    
//    override func viewDidDisappear(animated: Bool) {
//        super.viewDidDisappear(animated)
//        
//        print("disapeat")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Authenticate local player to GameCenter
        self.authenticateLocalPlayer()

        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            skView.showsPhysics = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
            
            // Notifications
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "showGameCenterStatistics", name: "getGameCenterStatistics", object: nil)
            
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }
    
    

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1 Show login if player is not logged in
                self.presentViewController(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.authenticated) {
                // 2 Player is already euthenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifer: String?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        self.gcDefaultLeaderBoard = leaderboardIdentifer!
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

    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: -Show the statistics of the user using GameCenter Leaderboard
    func showGameCenterStatistics() {
        let gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.Leaderboards
        gcVC.leaderboardIdentifier = "batBatFlyScore"
        self.presentViewController(gcVC, animated: true, completion: nil)
    }
    
    
}
