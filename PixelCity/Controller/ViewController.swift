//
//  ViewController.swift
//  PixelCity
//
//  Created by mostafa on 11/4/18.
//  Copyright © 2018 mostafa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage
class ViewController: UIViewController,UIGestureRecognizerDelegate{
    let locationmanager = CLLocationManager()
    var currentCoordinate:CLLocationCoordinate2D!
    var spinner : UIActivityIndicatorView?
    var screen = UIScreen.main.bounds.width
    var progresslbl:UILabel?
    var collectionView:UICollectionView?
    var flowlayout=UICollectionViewFlowLayout()
    var Arrayofphotos = [String]()
    var Images = [UIImage]()
    @IBOutlet weak var HeighCon: NSLayoutConstraint!
    
    @IBOutlet weak var dynamicview: UIView!
    
    
    let region:Double = 1000.0

    @IBAction func centerlocation(_ sender: Any) {
        centermap()
    }
    @IBOutlet weak var mapview: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationmanager.delegate = self
        locationmanager.requestAlwaysAuthorization()
        locationmanager.startUpdatingLocation()
        locationmanager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowlayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photocell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        dynamicview.addSubview(collectionView!)
        TouchTheMap()

    }

    


}
extension ViewController:MKMapViewDelegate{
    func addlabel(){
        
        
        progresslbl = UILabel()
        progresslbl?.frame = CGRect(x: (screen/2) - 100, y: 175, width: 200, height: 40)
        progresslbl?.font = UIFont(name: "Avenir Next", size: 17.0)
        progresslbl?.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        progresslbl?.textAlignment = .center
        collectionView?.addSubview(progresslbl!)
        
        
    }
    func removeprogress(){
        
        if progresslbl != nil{
            progresslbl?.removeFromSuperview()
        }
    }
    func Spinner(){
        
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screen/2) - ((spinner?.frame.width)!/2), y: 150)
        spinner?.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        spinner?.activityIndicatorViewStyle = .gray
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
     
    }
    func removespinner(){
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    
    func PullDown(){
        let swipe = UITapGestureRecognizer(target: self, action: #selector(ChangeHeightofView))
        
        mapview.addGestureRecognizer(swipe)
    }
    func PullUp(){
        
        
        HeighCon.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.dynamicview.layoutIfNeeded()
        }
    }
    @objc func ChangeHeightofView(){
        if HeighCon.constant == 300 {
            HeighCon.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.dynamicview.layoutIfNeeded()
            }
        }
        self.view.layoutIfNeeded()
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let PinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "reusableAnn")
        PinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        PinAnnotation.animatesDrop = true
        return PinAnnotation
    }
    func TouchTheMap(){
        
        let Pin = UILongPressGestureRecognizer(target: self, action: #selector(DropPin(touchmap:)))

    mapview.addGestureRecognizer(Pin)
    }
    
    func CancelSessions(){
        
        
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (DataSession, UploadData, DownloadData) in
            DataSession.forEach({$0.cancel()})
            DownloadData.forEach({$0.cancel()})
        }
    }
    func removeThePin(){
        for annotation in mapview.annotations{
            mapview.removeAnnotation(annotation)

        }
        
    }
    
    @objc func DropPin(touchmap:UITapGestureRecognizer){
        removeThePin()
        removespinner()
        removeThePin()
    Arrayofphotos = []
        Images = []
        collectionView?.reloadData()
        PullUp()
        PullDown()
        Spinner()
        addlabel()
        let toutchPoint = touchmap.location(in: mapview)
        let annotationCO = mapview.convert(toutchPoint, toCoordinateFrom: mapview)
        let annotation = DropAnnotation(coordinate: annotationCO, identifier: "reusableAnn")
        mapview.addAnnotation(annotation)
        print(FlickrUrl(ForKey: UrlKey, WithAnnotation: annotation))
        let annotationregion = MKCoordinateRegionMakeWithDistance(annotationCO, region*2, region*2)
        mapview.setRegion(annotationregion, animated: true)
        DownloadUrl(ForAnnotation: annotation) { (finished) in
            if finished {
                self.RetrieveImages(Handler: { (finished) in
                    if finished{
                        print("Load image")
                        self.removespinner()
                        self.removeprogress()
                        
                        self.collectionView?.reloadData()
                    }
                })
                }
                
            }
        }
    func RetrieveImages(Handler:@escaping(_ status:Bool)->()){
        Images = []
        for url in Arrayofphotos {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else { return }
                self.Images.append(image)
                self.progresslbl?.text = "\(self.Images.count)/\(self.Arrayofphotos.count) Downloading"
                
                if self.Images.count == self.Arrayofphotos.count {
                    Handler(true)
                }
                        })
            
        }
    }



    func DownloadUrl(ForAnnotation Annotation:DropAnnotation,Handler:@escaping(_ status:Bool)->()){
        Arrayofphotos = []
        Alamofire.request(FlickrUrl(ForKey: UrlKey, WithAnnotation: Annotation)).responseJSON { (response) in
            
            
            guard let json = response.result.value as? Dictionary<String,AnyObject> else{return}
            let photosDictionary = json["photos"] as! Dictionary<String,AnyObject>
                
                
            
            let photoDictArray = photosDictionary["photo"] as! [Dictionary<String,AnyObject>]
            for photo in photoDictArray{
                
                let PostUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.Arrayofphotos.append(PostUrl)
                
            }
            Handler(true)
        }
    }
    
    func centermap(){
        
        guard let coordinate = locationmanager.location?.coordinate else{return}
        let coordinateRegion  = MKCoordinateRegionMakeWithDistance(coordinate, region * 2, region * 2)
        mapview.setRegion(coordinateRegion, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return MKOverlayRenderer()
    }
}

extension ViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        mapview.userTrackingMode = .followWithHeading
    }
}

extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let imageFromIndex = Images[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let SelectedImage = Images[indexPath.row]
        guard let PopStoryBoard = storyboard?.instantiateViewController(withIdentifier: "PopVc") as? PopVc else {return}
        PopStoryBoard.FillPopVc(Image: SelectedImage)
        present(PopStoryBoard, animated: true, completion: nil)
    }
}




