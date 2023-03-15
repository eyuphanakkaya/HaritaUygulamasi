//
//  ListViewController.swift
//  HaritaUygulamasi
//
//  Created by Eyüphan Akkaya on 13.03.2023.
//

import UIKit
import CoreData

class ListViewController: UIViewController ,UITableViewDelegate ,UITableViewDataSource{

    
    @IBOutlet weak var tableView: UITableView!
    
    var isimDizi = [String]()
    var idDizi = [UUID]()
    var gidenIsim = ""
    var gidenId :UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(artiButtonTiklandi))
        veriGetir()
        // Do any additional setup after loading the view.
    }
    @objc func  artiButtonTiklandi(){
        performSegue(withIdentifier: "toMapsVC", sender: nil)
        
    }
    
    func veriGetir(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "Yer")
        do{
            let sonuclar = try context.fetch(request)
            for sonuc in sonuclar as! [NSManagedObject]{
                if let isim = sonuc.value(forKey: "isim") as? String {
                    isimDizi.append(isim)
                }
                if let id = sonuc.value(forKey: "id") as? UUID {
                    idDizi.append(id)
                }
            }
            
        }catch {
            print("Hata!!")
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizi.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        cell.textLabel?.text = isimDizi[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gidenIsim = isimDizi[indexPath.row]
        gidenId = idDizi[indexPath.row]
        performSegue(withIdentifier: "toMapsVC", sender: nil)
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC"{
            let destinationVC = segue.destination as! MapViewController
            destinationVC.secilenIsim = gidenIsim
            destinationVC.secilenId = gidenId 
        }
    }
    


}
