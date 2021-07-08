//
//  ViewController.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate {
    var coinManager = CoinManager()
    var uNotifications = NotificationModel()
    var lastUpdatedPrice : Double = 0.0
    var watchlistData : [WatchlistDataModel] = []
    var currentCryptoOfSelectedPicker = ""
    var currentPriceOfSelectedPicker = 0.0
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Watchlist.plist")
    var soundPlayer : AVAudioPlayer!
    var userData = UserDefaults.standard
    var colorIjo = #colorLiteral(red: 0, green: 0.3077625632, blue: 0.05179936439, alpha: 1)
    var colorAbu = #colorLiteral(red: 0.1843137255, green: 0.2078431373, blue: 0.2941176471, alpha: 1)
    @IBOutlet weak var bantuCuanOutlet: UILabel!
    @IBOutlet weak var coinViewOutlet: UIView!
    @IBOutlet weak var watchlistTitleOutlet: UILabel!
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var bitcoinLabel: UILabel!
    @IBOutlet weak var bitcoinCurrency: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var refreshButtonOutlet: UIButton!
    @IBOutlet weak var settingButtonOutlet: UIButton!
    @IBOutlet weak var addButtonOutlet: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        coinManager.delegate = self
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (_, _) in
        }
        loadWatchlistData()
        tableViewOutlet.reloadData()
        bantuCuanOutlet.textColor = colorAbu
        bitcoinLabel.textColor = colorAbu
        bitcoinCurrency.textColor = colorAbu
        watchlistTitleOutlet.text = "Crypto Watchlist"
        watchlistTitleOutlet.font = .boldSystemFont(ofSize: 25)
        watchlistTitleOutlet.textColor = colorAbu
        currentCryptoOfSelectedPicker = coinManager.currencyArray[0]
        coinManager.fetchCoin(crypto: coinManager.currencyArray[0])
        coinViewOutlet.layer.cornerRadius = 40
        refreshButtonOutlet.layer.cornerRadius = 15
        refreshButtonOutlet.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        refreshButtonOutlet.layer.shadowOffset =  CGSize(width: 0.0, height: 5.0)
        refreshButtonOutlet.layer.shadowOpacity = 1.0
        refreshButtonOutlet.layer.shadowRadius = 3
        refreshButtonOutlet.layer.masksToBounds = false
        refreshButtonOutlet.layer.cornerRadius = 15.0
        settingButtonOutlet.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        settingButtonOutlet.layer.shadowOffset =  CGSize(width: 0.0, height: 3.0)
        settingButtonOutlet.layer.shadowOpacity = 1.0
        settingButtonOutlet.layer.shadowRadius = 2
        settingButtonOutlet.layer.masksToBounds = false
        addButtonOutlet.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        addButtonOutlet.layer.shadowOffset =  CGSize(width: 0.0, height: 3.0)
        addButtonOutlet.layer.shadowOpacity = 1.0
        addButtonOutlet.layer.shadowRadius = 2
        addButtonOutlet.layer.masksToBounds = false
        tableViewOutlet.layer.cornerRadius = 15
        DispatchQueue.main.async {
            self.updateUI()
        }
    }

    func updateUI() {
        for data in watchlistData {
            coinManager.fetchCoinNoDelegate(crypto: data.name)
            RunLoop.current.run(until: Date()+1)
            data.price = coinManager.coinManagerLastPrice
        }
        saveWatchlistData()
    }

    // MARK: - BAGIAN BUTTON BUTTON

    @IBAction func settingPressed(_ sender: UIButton) {

        let alert = UIAlertController(title: "Suara Notifikasi", message: "Pilih suara notifikasimu!", preferredStyle: .alert)

        let action = UIAlertAction(title: "Suara A", style: .default) { (_) in
            self.setSound(musicName: "sound1")
            self.dismiss(animated: true, completion: nil)
        }

        let action2 = UIAlertAction(title: "Suara B", style: .default) { (_) in
            self.setSound(musicName: "sound2")
            self.dismiss(animated: true, completion: nil)
        }

        let action3 = UIAlertAction(title: "Suara C", style: .default) { (_) in
            self.setSound(musicName: "sound3")
            self.dismiss(animated: true, completion: nil)
        }

        let action4 = UIAlertAction(title: "Kembali", style: .destructive) { (_) in
            self.dismiss(animated: true, completion: nil)
        }

        alert.addAction(action)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(action4)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func refreshButton(_ sender: Any) {
        refreshButtonOutlet.isEnabled = false
        refreshButtonOutlet.alpha = 0.5
        DispatchQueue.main.async {
            self.bitcoinLabel.text = String(format: "%.1f", self.currentPriceOfSelectedPicker)
            self.updateUI()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.refreshButtonOutlet.isEnabled = true
            self.refreshButtonOutlet.alpha = 1
        }
    }
    @IBAction func addPressed(_ sender: UIButton) {
        var textFieldBatasAtas = UITextField()
        var textFieldBatasBawah = UITextField()
        let titleText = "Tambahkan \(currentCryptoOfSelectedPicker) ke Crypto Watchlist!"
        let messageText = "Masukan nilai batas bawah dan batas atas nilai crypto yang kalian inginkan dalam mata uang rupiah. Contoh: 2314.15123"
        let alert = UIAlertController(title: titleText , message: messageText , preferredStyle: .alert)
        let action = UIAlertAction(title: "Tambahkan", style: .default) { [self] (_) in
            if let atasText = textFieldBatasAtas.text, let bawahText = textFieldBatasBawah.text {
                if let atasTextDouble = Double(atasText), let bawahTextDouble = Double(bawahText) {
                    let newItemFromAlert = WatchlistDataModel()
                    newItemFromAlert.name = currentCryptoOfSelectedPicker
                    newItemFromAlert.price = currentPriceOfSelectedPicker
                    newItemFromAlert.limitAtas = atasTextDouble
                    newItemFromAlert.limitBawah = bawahTextDouble
                    bitcoinLabel.text = String(format: "%.1f", currentPriceOfSelectedPicker)
                    watchlistData.append(newItemFromAlert)
                    saveWatchlistData()
                } else {
                    let alert1 = UIAlertController(title: "Eror!", message: "Format nilai batas atas dan batas bawah harus dalam format angka dan tidak boleh kosong ya. Contoh: 12435.86349",
                                                   preferredStyle: .alert)
                    let action1 = UIAlertAction(title: "OK", style: .destructive) { (_) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    alert1.addAction(action1)
                    self.present(alert1, animated: true, completion: nil)
            }
        }
        }
        let action1 = UIAlertAction(title: "Kembali", style: .destructive) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Isi batas atas crypto disini"
            textFieldBatasAtas = alertTextField
        }
        alert.addTextField { (alertTextField2) in
            alertTextField2.placeholder = "Isi batas bawah crypto disini"
            textFieldBatasBawah = alertTextField2
        }

        alert.addAction(action)
        alert.addAction(action1)

        present(alert, animated: true, completion: nil)
    }
    // MARK: - BAGIAN MANIPULASI DATA

    func saveWatchlistData() {
        tableViewOutlet.reloadData()
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(watchlistData)
            try data.write(to: dataFilePath!)
        } catch {
            print("error coding item array, \(error)")
        }
    }

    func loadWatchlistData() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                watchlistData = try decoder.decode([WatchlistDataModel].self, from: data)
            } catch {
                print("error loading data, \(error)")
            }
        }
    }
    // MARK: - BAGIAN AVFOUNDATION
    func setSound(musicName: String , musicExtension: String = "wav") {
        let url = Bundle.main.url(forResource: musicName, withExtension: musicExtension)
        soundPlayer = try? AVAudioPlayer(contentsOf: url!)
        soundPlayer.play()
        userData.set(musicName+"."+musicExtension, forKey: "notificationSound")
    }
    // MARK: - BAGIAN TABLE DELEGATE
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            watchlistData.remove(at: indexPath.section)
//            tableView.deleteSections(IndexSet(indexPath), with: .fade)
            saveWatchlistData()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Bagian Table Data Source
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return watchlistData.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(50)
    }

//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return CGFloat(10)
//    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat(0)
        } else {
            return CGFloat(10)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cryptoCurrency = watchlistData[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "watchlistCell", for: indexPath)
        cell.textLabel?.text = cryptoCurrency.name
        cell.layer.cornerRadius = 20
        cell.textLabel?.font = .boldSystemFont(ofSize: 18)
        cell.textLabel?.textColor = colorAbu
//        cell.backgroundColor = UIColor(white: 1, alpha: 0.4)
//
        cell.detailTextLabel?.text = String(cryptoCurrency.price)
        cell.detailTextLabel?.font = .boldSystemFont(ofSize: 18)
        if cryptoCurrency.price > cryptoCurrency.limitAtas {
            cell.detailTextLabel?.textColor = colorIjo
        } else if cryptoCurrency.price < cryptoCurrency.limitBawah {
            cell.detailTextLabel?.textColor = .systemRed
        } else {
            cell.detailTextLabel?.textColor = colorAbu
        }
        return cell
    }
}

// MARK: - BAGIAN PICKERVIEW
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(25)
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coinManager.currencyArray.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let vvv = view as? UILabel { label = vvv }
        label.font = .boldSystemFont(ofSize: 25)
        label.text =  coinManager.currencyArray[row]
        label.textColor = colorAbu
        label.textAlignment = .center
        return label
    }
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//
//        coinManager.currencyArray[row]
//
//    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        coinManager.fetchCoin(crypto: coinManager.currencyArray[row])
        currentCryptoOfSelectedPicker = coinManager.currencyArray[row]
    }
}

// MARK: - Bagian CoinManagerDelegate
extension ViewController: CoinManagerDelegate {
    func didUpdateCoin (_ coinManager : CoinManager, coin: CoinModel) {
        DispatchQueue.main.async {
            self.bitcoinLabel.text = String(format: "%.1f", coin.lastPriceFromModel)
            self.bitcoinCurrency.text = "IDR"
            self.currentPriceOfSelectedPicker = Double(coin.lastPriceFromModel)
        }
    }
    func didFailWithError(error: Error) {
        print(error)
    }
}
