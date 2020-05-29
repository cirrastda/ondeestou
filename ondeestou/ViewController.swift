//
//  ViewController.swift
//  ondeestou
//
//  Created by Anderson Matuchenko on 28/05/20.
//  Copyright © 2020 Anderson Matuchenko. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var lblVelocidade: UILabel!
    @IBOutlet weak var lblLatitude: UILabel!
    @IBOutlet weak var lblLongitude: UILabel!
    @IBOutlet weak var lblEndereco: UILabel!
    
    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMap()
        // Do any additional setup after loading the view.
    }
    
    func initMap() {
        centerMap(latitude: -23.613351, longitude: -46.639821)
        initLocation()
    }

    func centerMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees, zoom: Double = 0.01) {
        let latLng = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let area = MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom)
        let regiao = MKCoordinateRegion(center: latLng, span: area)
        map.setRegion(regiao, animated: true)
    }
    
    func initLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func updateLocationData(location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        lblLatitude.text = String(latitude)
        lblLongitude.text = String(longitude)
        if location.speed > 0 {
            lblVelocidade.text = String(location.speed)
        } else {
            lblVelocidade.text = "--"
        }
        self.addressFromLocation(location: location, closure: { (address) in
            self.lblEndereco.text = address
        })
        
    }
    
    func parseAddressFromLocation(location: CLPlacemark) -> String {
        var retorno = ""
        if location.thoroughfare != nil {
            retorno += location.thoroughfare!
        }
        if location.subThoroughfare != nil {
            if retorno != "" { retorno += ", " }
            retorno += location.subThoroughfare!
        }
        if location.subLocality != nil {
            if retorno != "" { retorno += " - " }
            retorno += location.subLocality!
        }
        if location.locality != nil {
            if retorno != "" { retorno += " - " }
            retorno += location.locality!
        }
        if location.administrativeArea != nil {
            if retorno != "" { retorno += " - " }
            retorno += location.administrativeArea!
        }
        if location.country != nil {
            if retorno != "" { retorno += " - " }
            retorno += location.country!
        }
        return retorno
    }
    
    func addressFromLocation(location: CLLocation, closure: @escaping(String) -> ()) {
        
        CLGeocoder().reverseGeocodeLocation(location) { (reverseLocation, error) in
            if (error != nil) {
                print(error)
            } else {
                if let local = reverseLocation?.first {
                    let address = self.parseAddressFromLocation(location: local)
                    closure(address)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        self.centerMap(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        self.updateLocationData(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedWhenInUse {
            let alerta = UIAlertController(title: "Autorizar Localização", message: "Este aplicativo necessita permissão para acessar suas localizações", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "Abrir Configurações", style: .default, handler: { (alertaConfig) in
                if let config = NSURL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(config as URL)
                }
            }))
            alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            present(alerta,animated: true)
        }
    }
}

