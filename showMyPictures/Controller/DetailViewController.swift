//
//  DetailViewController.swift
//  showMyPictures
//
//  Created by António Rocha on 03/12/2021.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    
    var SelectedPictureCaption: String?
    var selectedPictureFilePath: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.largeTitleDisplayMode = .never
        
        if let caption = SelectedPictureCaption {
            title = caption
        }

        if let imageToLoad = selectedPictureFilePath {
            imageView.image = UIImage(contentsOfFile: imageToLoad.path)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }

}
