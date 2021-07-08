//
//  WatchlistData.swift
//  ByteCoin
//
//  Created by Jehnsen Hirena Kane on 04/05/21.
//  Copyright © 2021 The App Brewery. All rights reserved.
//

import UIKit
class WatchlistDataModel : Encodable, Decodable {
    var name :String = ""
    var price : Double = 0.0
    var limitAtas : Double = 0.0
    var limitBawah : Double = 0.0
}
