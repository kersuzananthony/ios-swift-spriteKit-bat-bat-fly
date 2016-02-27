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
    
    // Advertising: iAd features cannot be use
    // var interAd: ADInterstitialAd?
    // var interAdView: UIView?
    // var bannerView: ADBannerView?
    var closeButton: UIButton = UIButton(type: UIButtonType.System)
    var activityView: UIActivityIndicatorView = UIActivityIndicatorView()
    // var loadBannerViewSuccess: Bool = false
    // var loadInterAdViewTimer: NSTimer!
    // var loadInterAdViewCanceled: Bool = false
    
    func makeSpinner() {
        self.activityView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.activityView.center = self.view.center
        self.activityView.hidesWhenStopped = true
        self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.view.addSubview(self.activityView)
        self.activityView.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func removeSpinner() {
        self.activityView.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // For the moment, we do not want to display advertising
        //displayBannerAdvertising()
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showGameCenterStatistics", name: "classmentButton", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "shareTo:", name: "shareButton", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rateApp", name: "rateButton", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gameOver", name: "gameOver", object: nil)
    }
    
    func gameOver() {
        gamePlayTime++
        
        GameManager.sharedInstance.setHowManyPlayerPlayerGame(self.gamePlayTime)
        
        self.gameHasBegun = false
        
        // iAd features not working
//        if gamePlayTime % 5 == 0 {
//            self.displayFullscreenAdvertising()
//        } else {
//            displayGameScene()
//        }
        
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
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
            
            self.gameHasBegun = true
            
            // For the moment we do not want to load a banner advertising
            //self.loadBannerViewSuccess = false
            //displayBannerAdvertising()
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
                        print(leaderboardIdentifer!)
                        let leaderBoard = GKLeaderboard()

                        leaderBoard.identifier = leaderboardIdentifer!
                        leaderBoard.loadScoresWithCompletionHandler({ (score: [GKScore]?, error: NSError?) -> Void in
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
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shareTo(sender: NSNotification) {
        if let score = sender.object as? Int {
            let sentence = "Hey, I've played to \"Bat bat fly\" game and got \(score). Do you think you can get a better score? Go on, download the game and try!"
            let url = NSURL(string: "http://itunes.apple.com/app/id\(APP_ID)")!
            let image = UIImage(named: "bat")!
            let shareItem: [AnyObject] = [sentence, url, image]
            
            let activityViewController = UIActivityViewController(activityItems: shareItem, applicationActivities: nil)
            if #available(iOS 9.0, *) {
                activityViewController.excludedActivityTypes = [UIActivityTypeAirDrop,
                    UIActivityTypeAssignToContact,
                    UIActivityTypeCopyToPasteboard,
                    UIActivityTypeOpenInIBooks,
                    UIActivityTypePrint,
                    UIActivityTypeSaveToCameraRoll,
                    UIActivityTypeAddToReadingList]
            } else {
                activityViewController.excludedActivityTypes = [UIActivityTypeAirDrop,
                    UIActivityTypeAssignToContact,
                    UIActivityTypeCopyToPasteboard,
                    UIActivityTypePrint,
                    UIActivityTypeSaveToCameraRoll,
                    UIActivityTypeAddToReadingList]
            }
            
            
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: -Show the statistics of the user using GameCenter Leaderboard
    func showGameCenterStatistics() {
        let gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.Leaderboards
        gcVC.leaderboardIdentifier = "grp.batBatFlyLeaderboardId"
        self.presentViewController(gcVC, animated: true, completion: nil)
    }
    
    func rateApp() {
        let alertViewController = UIAlertController(title: "Rate", message: "Do you want to rate our game?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Later", style: .Cancel) { (action: UIAlertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let rateItAction = UIAlertAction(title: "Go Now!", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/id\(APP_ID)")!)
        }
        
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(rateItAction)
        
        self.presentViewController(alertViewController, animated: true, completion: nil)
    }
}

// Since Apple doesnt support new app for displaying advertising, this code will not be executed in the production app.
//extension GameViewController: ADBannerViewDelegate {
//    
//    func displayBannerAdvertising() {
//        prepareBannerView()
//    }
//    
//    func prepareBannerView() {
//        print(" --- Banner: Try Load ---")
//        // Attempt to load a new banner ad:
//        
//        if self.bannerView == nil {
//            self.bannerView = ADBannerView(frame: CGRectZero)
//            self.bannerView!.delegate = self
//            let screenRect = UIScreen.mainScreen().bounds
//            self.bannerView!.frame = CGRectMake(0, 0, screenRect.size.width, self.bannerView!.frame.size.height)
//            self.bannerView!.layer.zPosition = ZPosition.obstacle.rawValue
//        }
//    }
//    
//    func bannerFinished() {
//        self.bannerView?.removeFromSuperview()
//        self.bannerView = nil
//    }
//    
//    func showBannerView() {
//        self.view.addSubview(self.bannerView!)
//    }
//    
//    func bannerViewDidLoadAd(banner: ADBannerView!) {
//        print(" --- Banner: Load success --- ")
//        self.loadBannerViewSuccess = true
//        showBannerView()
//    }
//    
//    func bannerViewWillLoadAd(banner: ADBannerView!) {
//        print(" --- Banner: Unload --------")
//    }
//    
//    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
//        print(" --- Banner: Action Failed --- ")
//        
//        if loadBannerViewSuccess == false {
//            bannerFinished()
//        }
//    }
//    
//    func bannerViewActionDidFinish(banner: ADBannerView!) {
//        print(" --- Banner: Action Finish --- ")
//    }
//    
//    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
//        return true
//    }
//}
//
//extension GameViewController: ADInterstitialAdDelegate {
//    
//    func displayFullscreenAdvertising() {
//        
//        self.loadInterAdViewTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "cancelLoadAdvertising", userInfo: nil, repeats: false)
//        self.loadInterAdViewCanceled = false
//        makeSpinner()
//        bannerFinished()
//        
//        // Define a close button size:
//        self.closeButton.frame = CGRectMake(20, UIScreen.mainScreen().bounds.height - 64, 70, 44)
//        self.closeButton.layer.cornerRadius = 10
//        self.closeButton.layer.zPosition = ZPosition.userInterface.rawValue
//        // Give the close button some coloring layout:
//        self.closeButton.backgroundColor = UIColor.whiteColor()
//        self.closeButton.layer.borderColor = UIColor.blackColor().CGColor
//        self.closeButton.layer.borderWidth = 1
//        self.closeButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
//        // Wire up the closeAd function when the user taps the button
//        self.closeButton.addTarget(self, action: "closeAd:", forControlEvents: UIControlEvents.TouchDown)
//        // Some funkiness to get the title to display correctly every time:
//        self.closeButton.enabled = false
//        self.closeButton.setTitle("skip", forState: UIControlState.Normal)
//        self.closeButton.enabled = true
//        self.closeButton.setNeedsLayout()
//        
//        prepareAd()
//    }
//    
//    func cancelLoadAdvertising() {
//        print("Cancel load advertising")
//        self.adFinished()
//        self.removeSpinner()
//        self.loadInterAdViewCanceled = true
//    }
//    
//    func prepareAd() {
//        print(" --- AD: Try Load ---")
//        // Attempt to load a new ad:
//        interAd = ADInterstitialAd()
//        interAd?.delegate = self
//    }
//    
//    func showAd() -> Bool {
//        self.loadInterAdViewTimer.invalidate()
//        print("timer invalidate")
//        if interAd != nil && interAd!.loaded && !self.gameHasBegun {
//            interAdView = UIView()
//            interAdView!.frame = self.view!.bounds
//            self.view?.addSubview(interAdView!)
//            
//            interAd!.presentInView(interAdView!)
//            UIViewController.prepareInterstitialAds()
//            
//            interAdView!.addSubview(closeButton)
//        }
//        
//        // Return true if we're showing an ad, false if an ad can't be displayed:
//        return interAd?.loaded ?? false
//    }
//    
//    // When the user clicks the close button, route to the adFinished function:
//    func closeAd(sender: UIButton) {
//        print("close ad")
//        adFinished()
//    }
//    
//    func adFinished() {
//        self.loadInterAdViewTimer.invalidate()
//        closeButton.removeFromSuperview()
//        interAdView?.removeFromSuperview()
//        displayGameScene()
//    }
//    
//    // The ad loaded successfully (we don't need to do anything for the basic implementation)
//    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
//        print(" --- AD: Load Success ---")
//        removeSpinner()
//        
//        if !self.loadInterAdViewCanceled {
//            showAd()
//        }
//    }
//    
//    // The ad unloaded (we don't need to do anything for the basic implementation)
//    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
//        print(" --- AD: Unload --- ")
//    }
//    
//    // This is called if the user clicks into the interstitial, and then finishes interacting with the ad
//    // We'll call our adFinished function since we're returning to our app:
//    func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
//        print(" --- ADD: Action Finished --- ")
//    }
//    
//    func interstitialAdActionShouldBegin(interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
//        return true
//    }
//    
//    // Error in the ad load, print out the error
//    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
//        print(" --- AD: Error --- ")
//        print(error.localizedDescription)
//        if !self.loadInterAdViewCanceled {
//            self.loadInterAdViewCanceled = true
//            adFinished()
//            removeSpinner()
//            displayGameScene()
//        }
//    }
//
//}
