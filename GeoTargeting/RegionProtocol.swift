//
//  RegionProtocol.swift
//  GeoTargeting
//
//  Created by Eugene Trapeznikov on 4/25/16.
//  Copyright © 2016 Evgenii Trapeznikov. All rights reserved.
//

import CoreLocation


protocol RegionProtocol {
	var coordinate: CLLocation {get}
	var radius: CLLocationDistance {get}
	var identifier: String {get}

	func updateRegion()
}
