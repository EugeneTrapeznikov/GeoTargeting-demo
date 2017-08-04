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
	var monitoredRegions: Dictionary<String, Date> = [:]

	override func viewDidLoad() {
		super.viewDidLoad()

		// setup locationManager
		locationManager.delegate = self;
		locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;

		// setup mapView
		mapView.delegate = self
		mapView.showsUserLocation = true
		mapView.userTrackingMode = .follow

		// setup test data
		setupData()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// status is not determined
		if CLLocationManager.authorizationStatus() == .notDetermined {
			locationManager.requestAlwaysAuthorization()
		}
		// authorization were denied
		else if CLLocationManager.authorizationStatus() == .denied {
			showAlert("Location services were previously denied. Please enable location services for this app in Settings.")
		}
		// we do have authorization
		else if CLLocationManager.authorizationStatus() == .authorizedAlways {
			locationManager.startUpdatingLocation()
		}
	}

	func setupData() {
		// check if can monitor regions
		if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {

			// region data
			let title = "Lorrenzillo's"
			let coordinate = CLLocationCoordinate2DMake(37.703026, -121.759735)
			let regionRadius = 300.0

			// setup region
			let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
				longitude: coordinate.longitude), radius: regionRadius, identifier: title)
			locationManager.startMonitoring(for: region)

			// setup annotation
			let restaurantAnnotation = MKPointAnnotation()
			restaurantAnnotation.coordinate = coordinate;
			restaurantAnnotation.title = "\(title)";
			mapView.addAnnotation(restaurantAnnotation)

			// setup circle
			let circle = MKCircle(center: coordinate, radius: regionRadius)
			mapView.add(circle)
		}
		else {
			print("System can't track regions")
		}
	}

	// MARK: - MKMapViewDelegate

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let circleRenderer = MKCircleRenderer(overlay: overlay)
		circleRenderer.strokeColor = UIColor.red
		circleRenderer.lineWidth = 1.0
		return circleRenderer
	}

	// MARK: - CLLocationManagerDelegate

	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		showAlert("enter \(region.identifier)")
		monitoredRegions[region.identifier] = Date()
	}

	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		showAlert("exit \(region.identifier)")
		monitoredRegions.removeValue(forKey: region.identifier)
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		updateRegionsWithLocation(locations[0])
	}

	// MARK: - Comples business logic

	func updateRegionsWithLocation(_ location: CLLocation) {

		let regionMaxVisiting = 10.0
		var regionsToDelete: [String] = []

		for regionIdentifier in monitoredRegions.keys {
			if Date().timeIntervalSince(monitoredRegions[regionIdentifier]!) > regionMaxVisiting {
				showAlert("Thanks for visiting our restaurant")

				regionsToDelete.append(regionIdentifier)
			}
		}

		for regionIdentifier in regionsToDelete {
			monitoredRegions.removeValue(forKey: regionIdentifier)
		}
	}

	// MARK: - Helpers

	func showAlert(_ title: String) {
		let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
		}))
		self.present(alert, animated: true, completion: nil)

	}
}

