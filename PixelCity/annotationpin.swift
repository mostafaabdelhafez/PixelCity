//
//  annotationpin.swift
//  PixelCity
//
//  Created by mostafa on 11/4/18.
//  Copyright © 2018 mostafa. All rights reserved.
//

import Foundation
import MapKit
class DropAnnotation:NSObject,MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var identifier:String
    init(coordinate:CLLocationCoordinate2D,identifier:String){
        
        self.coordinate=coordinate
        self.identifier=identifier
        super.init()
    }
    
    
    
    
}
