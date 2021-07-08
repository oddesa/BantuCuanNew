//
//  SceneDelegate.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//




import UIKit
import UserNotifications


class SceneDelegate: UIResponder, UIWindowSceneDelegate, CoinManagerDelegate {
    
    
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("sceneDidBecomeActive")
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        print("scene")
    }
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        print("sceneDidDisconnect")
    }
    
    
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print("sceneWillResignActive")
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("sceneWillEnterForeground")
    }
    
    
    
    
    
    
    
    var coinManager1 = CoinManager()
    var uNotifications = NotificationModel()
    var backgroundWatchlistData : [WatchlistDataModel] = []
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Watchlist.plist")
    var vc = ViewController()
    
    var triggerCoinArray : [Double] = []
    var window: UIWindow?
    var watchlistDataIndex = 0
    var firtsPriceReference = 0.0
    var currentPrice = 0.0
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        print("scenedidenterBackground")
        watchlistDataIndex = 0
        coinManager1.delegate = self
        loadWatchlistData()
        
        
        for data in backgroundWatchlistData{
            
            firtsPriceReference = data.price
            print(data.price)
            coinManager1.fetchCoin(crypto: data.name)
            RunLoop.current.run(until: Date()+1.5)
            print("ini current price\(currentPrice)")
            
            while firtsPriceReference == currentPrice {
                coinManager1.fetchCoin(crypto: data.name)
                RunLoop.current.run(until: Date()+1.5)
                print("ini dari background \(data.name)")
                print(currentPrice)
            }
            
            if currentPrice > firtsPriceReference {
                uNotifications.prepare(body: "Sekarang harga \(data.name) sudah naik sampai Rp. " + String(format: "%.1f", currentPrice) + "!!!")
            } else {
                uNotifications.prepare(body: "Sekarang harga \(data.name) sudah turun sampai Rp. " + String(format: "%.1f", currentPrice) + "!!!")
            }
            
        }
            //            coinManager1.fetchCoinNoDelegate(crypto: data.name)
            
            
           
            
           
            
        
        
        
        //        for _ in 1...4{
        //            for data in backgroundWatchlistData {
        //                while data.price == data.price {
        //                    <#code#>
        //                }
        //            }
        //        }
        
        
        
        
        
        
        
        //        for _ in 1...2 {
        //            coinManager1.fetchCoin(crypto: "BTC")
        //            RunLoop.current.run(until: Date()+3)
        //        }
        //
        //
        //        print(self.coinArray)
        
        
        //
        //
        //        uNotifications.prepare()
    }
    
    
    func didUpdateCoin(_ coinManager: CoinManager, coin: CoinModel) {
        self.currentPrice = coin.lastPriceFromModel
        //        self.triggerCoinArray.append(coin.lastPriceFromModel)
        //        self.lastLastCoinPrice = coin.lastPriceFromModel
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func saveWatchlistData() {
        
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(backgroundWatchlistData)
            try data.write(to: dataFilePath!)
        } catch {
            print("error coding item array, \(error)")
        }
    }
    
    func loadWatchlistData() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                backgroundWatchlistData = try decoder.decode([WatchlistDataModel].self, from: data)
            } catch {
                print("error loading data, \(error)")
            }
        }
    }
    
    
    
}

extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}

