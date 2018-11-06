//
//  constants.swift
//  PixelCity
//
//  Created by mostafa on 11/5/18.
//  Copyright © 2018 mostafa. All rights reserved.
//

import Foundation
import UIKit
//let UrlKey = "4fedea1965813f38a018c25e98bdbce7"
let UrlKey="8c839181e4e9a023c45b37e997ef17cd"




func FlickrUrl(ForKey ApiKey:String,WithAnnotation Annotation:DropAnnotation)->String{
    
    let FinalUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(UrlKey)&lat=\(Annotation.coordinate.latitude)&lon=\(Annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=2&format=json&nojsoncallback=1"
    return FinalUrl
}
