//
//  ViewController.swift
//  iOSAssignment
//
//  Created by Smbat Tumasyan on 4/19/18.
//  Copyright © 2018 Smbat Tumasyan. All rights reserved.
//

import UIKit


//------------------------------------------------------------------------------------------
// MARK: - Proerties
//------------------------------------------------------------------------------------------

let screenWidth = UIScreen.main.bounds.size.width

var deviceScale: CGFloat {
    get {
        return   screenWidth / 375.0
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var pickedImage: UIImageView!
    var imageSize:CGRect? = nil
    
    var dashedLineWidth:CGFloat?
    var dashedLineHeight:CGFloat?
    var dashedLineX:CGFloat?
    var dashedLineY:CGFloat?
    


//------------------------------------------------------------------------------------------
// MARK: - Life Cycle
//------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//------------------------------------------------------------------------------------------
// MARK: - User Actions
//------------------------------------------------------------------------------------------
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        if self.pickedImage.image == nil {
            return
        }

        self.setDashedLine()
        if let dashedLineX = dashedLineX, let dashedLineY = dashedLineY, let dashedLineWidth = dashedLineWidth, let dashedLineHeight = dashedLineHeight {

            let cropedImage = self.view.snapshot(of: CGRect(x: dashedLineX, y: dashedLineY, width: dashedLineWidth, height: dashedLineHeight))
            
            self.pickedImage.image = cropedImage
            UIImageWriteToSavedPhotosAlbum(cropedImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @IBAction func handleRotation(_ sender: UIRotationGestureRecognizer) {

        sender.view?.transform = (sender.view?.transform)!.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        
        guard sender.view != nil else { return }
        
        if sender.state == UIGestureRecognizerState.began || sender.state == UIGestureRecognizerState.changed {
            
            if sender.scale < 1.0 {
                if self.pickedImage.frame.size.width < 290 {
                    return
                }
            } else if (sender.scale > 1.0) {
                if self.pickedImage.frame.size.width > 1500 {
                    return
                }
            }
            
            sender.view?.transform = (sender.view?.transform)!.scaledBy(x: sender.scale, y: sender.scale)
            sender.scale = 1
            
        }
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        
        self.setDashedLine()
        
        if sender.state == .began || sender.state == .changed {

            let translation = sender.translation(in: self.view)
            UIView .animate(withDuration: 0.2) {
                sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
                sender.setTranslation(CGPoint.zero, in: self.view)
            }
            
        }
    }
    
    @IBAction func chooseImageAction(_ sender: Any) {
        
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    

//------------------------------------------------------------------------------------------
// MARK: - Private methods
//------------------------------------------------------------------------------------------
    
    // Add image to Library
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func setDashedLine() {
        var topLeftView:UIView?
        var topRightView:UIView?
        var bottomLeftView:UIView?
        
    
        
        for pointView in self.view.subviews {
            if pointView.tag == 1 {
                
                topLeftView = pointView
            } else if pointView.tag == 2 {
                
                topRightView = pointView
            } else if pointView.tag == 3 {
                
                bottomLeftView = pointView
            } else if pointView.tag == 4 {
                
                bottomLeftView = pointView
            }
            
        }
        
        self.dashedLineX = topLeftView?.center.x
        self.dashedLineY = topLeftView?.center.y
        
        self.dashedLineWidth  = topRightView!.center.x - topLeftView!.center.x
        self.dashedLineHeight = bottomLeftView!.center.y - topLeftView!.center.y
    }
}

//------------------------------------------------------------------------------------------
// MARK: - Image PickerController Delegate
//------------------------------------------------------------------------------------------

extension ViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.pickedImage.image = image?.setImageNewSize()
        self.view.addDashedBorder()
        
        picker.dismiss(animated: true, completion: nil)
    }
}


//------------------------------------------------------------------------------------------
// MARK: - UIView extention
//------------------------------------------------------------------------------------------

extension UIView {
    

    func addDashedBorder() {
        //Create a CAShapeLayer
       _ = layer.sublayers?.filter({ $0.name == "DashedLine" }).map({ $0.removeFromSuperlayer() })
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColorFromRGB(rgbValue: 0x00a9e8).cgColor
        shapeLayer.lineWidth   = 3
    
        shapeLayer.lineDashPattern = [2,3]
        shapeLayer.name = "DashedLine"
        
        
        let topLeftImg    = createPointImage()
        topLeftImg.tag    = 1
        topLeftImg.center = CGPoint(x: 60*deviceScale, y: 210*deviceScale)
        
        let topRightImg    = createPointImage()
        topRightImg.tag    = 2
        topRightImg.center = CGPoint(x: 315*deviceScale, y: 210*deviceScale)
        
        let bottomRightImg    = createPointImage()
        bottomRightImg.tag    = 4
        bottomRightImg.center = CGPoint(x: 315*deviceScale, y: 440*deviceScale)
        
        let bottomLeftImg    = createPointImage()
        bottomLeftImg.tag    = 3
        bottomLeftImg.center = CGPoint(x: 60*deviceScale, y: 440*deviceScale)
        
        
        
        let path = CGMutablePath()
        path.addLines(between: [topLeftImg.center,
                                topRightImg.center])
        
        path.addLines(between: [topRightImg.center,
                                bottomRightImg.center])
        
        path.addLines(between: [bottomRightImg.center,
                                bottomLeftImg.center])
        
        path.addLines(between: [bottomLeftImg.center,
                                topLeftImg.center])
        shapeLayer.path = path

        self.addSubview(topLeftImg)
        self.addSubview(topRightImg)
        self.addSubview(bottomLeftImg)
        self.addSubview(bottomRightImg)
        
        layer.addSublayer(shapeLayer)
    }
    
    func removeDashedLine() {
        _ = layer.sublayers?.filter({ $0.name == "DashedLine" }).map({ $0.removeFromSuperlayer() })
        _ = subviews.filter({$0.tag == 1 || $0.tag == 2 || $0.tag == 3 || $0.tag == 4}).map({$0.removeFromSuperview()})
    }
    
    func createPointImage() -> UIImageView {
        let imageView   = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 4, height: 4)
        let pointImg    = UIImage(named: "img")
        imageView.image = pointImg
        return imageView
    }
    
    
    func snapshot(of rect: CGRect? = nil) -> UIImage? {
        
        
        UIGraphicsBeginImageContext(self.bounds.size)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image?.crop(rect: rect!)
    }
    
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}


//------------------------------------------------------------------------------------------
// MARK: - UIImage Extention
//------------------------------------------------------------------------------------------

extension UIImage {
    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x = rect.origin.x + 3
        rect.origin.y += 3
        rect.size.width -= 5
        rect.size.height -= 5

        let imageRef = self.cgImage!.cropping(to: rect)
        let image    = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        
        return image
    }
    
    func setImageNewSize() -> UIImage {
        let newSize = CGSize(width: 288.0, height: 288.0)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

