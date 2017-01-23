//
//  CLLocationExtension.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 23..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    // CLLocation 으로 주소 Get 함수
    func addressFromCLLocation() -> String? {
        var address:String?
        // 한국에 맞게 거꾸로 로케이션 지정
        let geoCoder = CLGeocoder.init()
        geoCoder.reverseGeocodeLocation(self) { (placemarks, error) -> Void in
            if error != nil {
                return
            }
            guard let placemark = placemarks?.first,
                let addrList = placemark.addressDictionary?["FormattedAddressLines"] as? [String] else {
                    return
            }
            address = addrList.joined(separator: " ")
        }
        return address
    }
}
