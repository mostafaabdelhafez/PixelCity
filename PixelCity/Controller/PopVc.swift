//
//  PopVcViewController.swift
//  PixelCity
//
//  Created by mostafa on 11/6/18.
//  Copyright © 2018 mostafa. All rights reserved.
//

import UIKit

class PopVc: UIViewController {

    @IBOutlet weak var ImageView: UIImageView!
    var PopImage:UIImage!
    
    func FillPopVc(Image:UIImage){
        
        PopImage = Image
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageView.image = PopImage
        TapToBack()
        

    }
    func TapToBack(){
        
        let TapOnThePhoto = UITapGestureRecognizer(target: self, action: #selector(DismissThisVc))
        view.addGestureRecognizer(TapOnThePhoto)
        
    }
    @objc func DismissThisVc(){
        
        self.dismiss(animated: true, completion: nil)
    }

    
}
