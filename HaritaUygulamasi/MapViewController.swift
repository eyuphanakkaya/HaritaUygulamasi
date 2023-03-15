//
//  ViewController.swift
//  HaritaUygulamasi
//
//  Created by Eyüphan Akkaya on 13.03.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    
    @IBOutlet weak var isimTextField: UITextField!
    
    @IBOutlet weak var aciklamaTextField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager() /*konumla ilgili olayları ele almaya yarar başladım durdurmak gibi*/
    var secilenLatitude = Double()
    var secilenLongidute = Double()
    var secilenIsim = ""
    var secilenId : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongidute = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest /*konumun tam olarak nereden almamızı istiyo*/
        locationManager.requestWhenInUseAuthorization()/*kullanıcıdan lokasyon için izin isteme*/
        locationManager.startUpdatingLocation()
        
        
       
        
        if secilenIsim  != "" {
              
            if let uuidString =  secilenId?.uuidString {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let context = appDelegate?.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                
                do {
                    let sonuclar = try context?.fetch(fetchRequest)
                    if sonuclar!.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            if let isim = sonuc.value(forKey: "isim") as? String {
                                annotationTitle = isim
                                if let not = sonuc.value(forKey: "not") as? String {
                                    annotationSubtitle = not
                                    if let latitude = sonuc.value(forKey: "latitude") as? Double {
                                        annotationLatitude = latitude
                                        if let longidute = sonuc.value(forKey: "longidute") as? Double {
                                            annotationLongidute = longidute
                                            
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubtitle
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongidute)
                                            annotation.coordinate = coordinate
                                           
                                            mapView.addAnnotation(annotation)
                                            isimTextField.text = annotationTitle
                                            aciklamaTextField.text = annotationSubtitle
                                            
                                            locationManager.stopUpdatingLocation()
                                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            mapView.setRegion(region, animated: true )
                                            
                                        }
                                    }
                                }
                            }
                           
                            
                            
                            
                        }
                    }
                }catch {
                    print("Hata!")
                }
            }
            
            
        }
    }
    
     func mapView(_ mapView: MKMapView, viewFor annotation : MKAnnotation) -> MKAnnotationView? {
         if annotation is MKUserLocation {/*eğer kullanıcının konumuysa boş döndür*/
             return nil
         }
         let reusId = "benimAnnotation"
         var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusId)
         
         if pinView == nil {
             pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusId)
             pinView?.canShowCallout = true
             pinView?.tintColor = .red
             let button = UIButton(type: .detailDisclosure)
             pinView?.rightCalloutAccessoryView = button
         }else {
             pinView?.annotation = annotation
         }
         return pinView
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if secilenIsim != "" {
            var requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongidute)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarkDizi, hata in
                if let placemarks = placemarkDizi {
                    if placemarks.count > 0 {
                        let yeniPlacemark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: yeniPlacemark)
                        item.name = self.annotationTitle
                        
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
                    
            }
        }

    }
    
    
    @objc func konumSec(gestureReconizer : UILongPressGestureRecognizer)/*gesture yi burada da kullanabilmek için */ {
        if gestureReconizer.state == .began{/*dokunma durumu eğer başladıysa*/
            let dokunulanDurum = gestureReconizer.location(in: mapView)/*dokunulduğu nokta*/
            let dokunulanKoordinat = mapView.convert(dokunulanDurum, toCoordinateFrom: mapView)
            /*dokunduğumuz noktayı kordinata döndürmeye yarıyor */
            
            secilenLatitude = dokunulanKoordinat.latitude/*dokunduğun yerlerden enlem ve boylamı al */
            secilenLongidute = dokunulanKoordinat.longitude
            
            
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKoordinat
            annotation.title = isimTextField.text
            annotation.subtitle = aciklamaTextField.text
            mapView.addAnnotation(annotation )
            /*işaretlemeye yarar*/
            
        }
        
    }
 
    
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      if secilenIsim == "" {
          let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)/*konum kordinatını bulmak için*/
          let span = MKCoordinateSpan(latitudeDelta : 0.01 , longitudeDelta : 0.01)/*belirttiğin böylgenin genişlik ve uzunluğu */
          let region = MKCoordinateRegion(center: location, span: span)
          mapView.setRegion(region, animated: true)/*haritamızda bir yere gitmek istersek kullanırızı*/
      }
       
     }/*kullanıcının enlem ve boyla mını almak için (bu fonksiyonda locationmanager a her güncelleme olduğunda benim haritamı güncelle diyorum )*/
    
   

    @IBAction func kaydetTiklandi(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        yeniYer.setValue(isimTextField.text, forKey: "isim")
        yeniYer.setValue(aciklamaTextField.text, forKey: "not")
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(secilenLongidute, forKey: "longidute")
        yeniYer.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("Kaydedildi")
        }catch{
            print("hata!!")
        }
        
      
        
    }
    
}

