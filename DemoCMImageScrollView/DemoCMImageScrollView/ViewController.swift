//
//  ViewController.swift
//  DemoCMImageScrollView
//
//  Created by cm0630 on 2020/8/11.
//  Copyright © 2020 CM_iOS. All rights reserved.
//

import UIKit
import CMImageScrollView

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    private lazy var imageScrollView: CMImageScrollView = {
        return CMImageScrollView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        
        let image = UIImage(named: "apple")
        imageView.image = image
    }

    // MARK: - IBAction
    @IBAction func zoomInButtonDidTap(_ sender: Any) {
        
        imageScrollView.zoomIn(imageView: imageView, on: view)
    }
}

