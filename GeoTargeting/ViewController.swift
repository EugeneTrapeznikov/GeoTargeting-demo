//
//  ViewController.swift
//  GeoTargeting
//
//  Created by Eugene Trapeznikov on 4/23/16.
//  Copyright © 2016 Evgenii Trapeznikov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

	@IBOutlet weak var mapView: MKMapView!

	let locationManager = CLLocationManager()
	var monitoredRegions: Dictionary<String, NSDate> = [:]

	override func viewDidLoad() {
		super.viewDidLoad()

		// setup locationManager
		locationManager.delegate = self;
		locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;

		// setup mapView
		mapView.delegate = self
		mapView.showsUserLocation = true
		mapView.userTrackingMode = .Follow

		// setup test data
		setupData()
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		// status is not determined
		if CLLocationManager.authorizationStatus() == .NotDetermined {
			locationManager.requestAlwaysAuthorization()
		}
		// authorization were denied
		else if CLLocationManager.authorizationStatus() == .Denied {
			showAlert("Location services were previously denied. Please enable location services for this app in Settings.")
		}
		// we do have authorization
		else if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
			locationManager.startUpdatingLocation()
		}
	}

	func setupData() {
		// check if can monitor regions
		if CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion.self) {

			// region data
			let title = "Lorrenzillo's"
			let coordinate = CLLocationCoordinate2DMake(37.703026, -121.759735)
			let regionRadius = 300.0

			// setup region
			let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
				longitude: coordinate.longitude), radius: regionRadius, identifier: title)
			locationManager.startMonitoringForRegion(region)

			// setup annotation
			let restaurantAnnotation = MKPointAnnotation()
			restaurantAnnotation.coordinate = coordinate;
			restaurantAnnotation.title = "\(title)";
			mapView.addAnnotation(restaurantAnnotation)

			// setup circle
			let circle = MKCircle(centerCoordinate: coordinate, radius: regionRadius)
			mapView.addOverlay(circle)
		}
		else {
			print("System can't track regions")
		}
	}

	// MARK: - MKMapViewDelegate

	func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
		let circleRenderer = MKCircleRenderer(overlay: overlay)
		circleRenderer.strokeColor = UIColor.redColor()
		circleRenderer.lineWidth = 1.0
		return circleRenderer
	}

	// MARK: - CLLocationManagerDelegate

	func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
		showAlert("enter \(region.identifier)")
		monitoredRegions[region.identifier] = NSDate()
	}

	func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
		showAlert("exit \(region.identifier)")
		monitoredRegions.removeValueForKey(region.identifier)
	}

	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		updateRegionsWithLocation(locations[0])
	}

	// MARK: - Comples business logic

	func updateRegionsWithLocation(location: CLLocation) {

		let regionMaxVisiting = 10.0
		var regionsToDelete: [String] = []

		for regionIdentifier in monitoredRegions.keys {
			if NSDate().timeIntervalSinceDate(monitoredRegions[regionIdentifier]!) > regionMaxVisiting {
				showAlert("Thanks for visiting our restaurant")

				regionsToDelete.append(regionIdentifier)
			}
		}

		for regionIdentifier in regionsToDelete {
			monitoredRegions.removeValueForKey(regionIdentifier)
		}
	}

	// MARK: - Helpers

	func showAlert(title: String) {
		let alert = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) in
			alert.dismissViewControllerAnimated(true, completion: nil)
		}))
		self.presentViewController(alert, animated: true, completion: nil)

	}
}

