//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoin (_ coinManager : CoinManager, coin : CoinModel)
    func didFailWithError(error: Error)
}



class CoinManager {
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/"
    let apiKey = "/IDR?apikey=DC48CE5B-EE5E-4F2B-AE22-D0ECF0C25FBE"
    let apiKey2 = "/IDR?apikey=8B444D02-52BA-4D65-B344-EA89C7FDF9AB"
    let apiKey3 = "/IDR?apikey=9A097986-3C6A-4740-950C-A0CB84EE79BA"
    let apiKey4 = "/IDR?apikey=722037DB-66C3-479B-A812-A47F34C9780B"
    var delegate : CoinManagerDelegate?
    var watchlistDataCoinManager : [WatchlistDataModel] = []
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Watchlist.plist")
    var coinManagerLastPrice = 0.0
    
    
    let currencyArray = ["ETH", "DOGE", "BTC","XRP", "USDT"]
    
    func fetchCoin(crypto : String) {
        let urlString = "\(baseURL)\(crypto)\(apiKey2)"
        getCoinPrice(for: urlString)
    }
    
    
    
    func getCoinPrice(for alamat : String){
        if let url = URL(string: alamat){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let coin = self.parseJSON(safeData){
                        self.delegate?.didUpdateCoin(self, coin: coin)
                    }
                }
            }
            
            task.resume()
            
        }
    }
    
    func fetchCoinNoDelegate(crypto: String) {
        let urlString = "\(baseURL)\(crypto)\(apiKey)"
        getCoinPriceNoDelegate(for: urlString)
    }
    
    
//    func saveWatchlistData() {
//
//        let encoder = PropertyListEncoder()
//
//        do {
//            let data = try encoder.encode(watchlistDataCoinManager)
//            try data.write(to: dataFilePath!)
//        } catch {
//            print("error coding item array, \(error)")
//        }
//    }
//
//    func loadWatchlistData() {
//        if let data = try? Data(contentsOf: dataFilePath!) {
//            let decoder = PropertyListDecoder()
//            do {
//                watchlistDataCoinManager = try decoder.decode([WatchlistDataModel].self, from: data)
//            } catch {
//                print("error loading data, \(error)")
//            }
//        }
//    }
    
    
    func getCoinPriceNoDelegate(for alamat : String){
        if let url = URL(string: alamat){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    print("error di getcoinpricenodelegate, \(String(describing: error))")
                    return
                }
                if let safeData = data {
                    if let coinPrice = self.parseJSONNoDelegate(safeData){
                        self.coinManagerLastPrice = coinPrice
                    }
                }
            }
            
            task.resume()
            
        }
    }
    
    
    func parseJSONNoDelegate(_ data : Data) -> Double? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            return lastPrice
            
        } catch {
            print("error dari parsejsonnodelegate, \(error)")
            return nil
        }
    }
    
    func parseJSON(_ data : Data) -> CoinModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            let currency = decodedData.asset_id_quote
            let coin = CoinModel(lastPriceFromModel: lastPrice, currency: currency)
//            print(coin.lastPriceFromModel)
            return coin
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
