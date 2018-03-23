//
//  PreviewViewController.swift
//  Snapshot Protoype 1
//
//  Created by Benton Robertson on 2018-03-02.
//  Copyright © 2018 Snapshot. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    
    @IBOutlet weak var photo: UIImageView!
    var image :UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image
        // Do any additional setup after loading the view
    }

    @IBAction func cancelButton_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveButton_TouchUpInside(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
