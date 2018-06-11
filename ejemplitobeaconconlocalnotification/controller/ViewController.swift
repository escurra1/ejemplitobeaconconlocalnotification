//
// Maurihño Enrique Escurra Colquis 2018

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet weak var beaconLabel: UILabel!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var beaconcercado : CLBeacon?
    var max: Double = 999.0
    var existbeacons = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadLocationManager()
        self.loadNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startScanning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopScanning()
    }
    
    func loadLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func loadNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
            if error != nil {
                print("Authorization Unsuccessfull")
            } else {
                print("Authorization Successfull")
            }
        })
        UNUserNotificationCenter.current().delegate = self
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "uuid")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 1000, identifier: "beacon")
        self.locationManager.startMonitoring(for: beaconRegion)
        self.locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func stopScanning() {
        let uuid = UUID(uuidString: "uuid")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 1000, identifier: "beacon")
        self.locationManager.stopMonitoring(for: beaconRegion)
        self.locationManager.stopRangingBeacons(in: beaconRegion)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    self.startScanning()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            existbeacons = 1
            if(beaconcercado == nil) {
                beaconcercado = beacons[0]
            }
            self.max = 999.0
            var beaconcito = beacons[0]
            for beacon in beacons {
                if(beacon.accuracy <= self.max && beacon.proximity != .unknown) {
                    self.max = beacon.accuracy
                    beaconcito = beacon
                    if(beacon.minor == NSNumber(integerLiteral: 1013)) {
                        let content = UNMutableNotificationContent()
                        content.title = "Beacon 2"
                        content.subtitle = "Beacon y Label 2"
                        content.body = "Este es el beacon y label 2 para comprobar"
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
                        let request = UNNotificationRequest(identifier: "notificationBeacon", content:  content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                        self.beaconLabel.text = "Beacon 2"
                    } else {
                        let content = UNMutableNotificationContent()
                        content.title = "Beacon 1"
                        content.subtitle = "Beacon y Label 1"
                        content.body = "Este es el beacon y label 1 para comprobar"
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
                        let request = UNNotificationRequest(identifier: "notificationBeacon", content:  content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                        self.beaconLabel.text = "Beacon 1"
                    }
                }
            }
            beaconcercado = beaconcito
            if((beaconcercado?.accuracy)! <= 3.0) {
                print("Region encontrada")
            }
        } else {
            existbeacons = 0
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if (state == CLRegionState.inside){
            print("Beacon dentro de la region")
        } else if (state == CLRegionState.outside) {
            print("Beacon fuera de la region")
        } else {
            print("Beacon en otra region")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}
