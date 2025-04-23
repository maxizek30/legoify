//
//  ResultsViewController.swift
//  legoify
//
//  Created by Max Lopez on 4/20/25.
//

import UIKit

class ResultsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var legoifiedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = legoifiedImage
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
