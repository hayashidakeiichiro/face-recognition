//
//  Lcamera.swift
//  Face recognition
//
//  Created by 林田計一郎 on 2022/04/17.
//

import UIKit

import DKImagePickerController
import Vision

class Lcamera: UIViewController {
    
    

    @IBOutlet weak var imgview1: UIImageView!
    var imagelist:[UIImage]=[]
    var i = 0
    @IBOutlet weak var Sbtn: UIButton!
    
    @IBOutlet weak var Obtn: UIButton!
    @IBOutlet weak var listview: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        Sbtn.layer.cornerRadius=10
        Sbtn.layer.shadowOpacity=0.3
        Sbtn.layer.shadowRadius=5
        Sbtn.layer.shadowOffset=CGSize(width: 7, height: 7)
        
        Obtn.layer.cornerRadius=10
        Obtn.layer.shadowOpacity=0.3
        Obtn.layer.shadowRadius=5
        Obtn.layer.shadowOffset=CGSize(width: 7, height: 7)
        
        self.Obtn.isEnabled = false

        // Do any additional setup after loading the view.
    }
   
    @IBAction func selectPhoto(_ sender: Any) {
        let pickerController = DKImagePickerController()

        // 選択可能な枚数を20にする
        pickerController.maxSelectableCount = 100
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            
            // 選択された画像はassetsに入れて返却されるのでfetchして取り出す
            for (index,asset) in assets.enumerated() {
                asset.fetchFullScreenImage(completeBlock: { (image, info) in
                    
                    let ciImage = CIImage(image: image!)!
                    var i = 0
                    var maxS:Double = 0
                    var maxindex = 0
                    var uiimg = image!
                    if let orientation = CGImagePropertyOrientation(rawValue: UInt32(uiimg.imageOrientation.rawValue)) {
                        let handler = VNImageRequestHandler(ciImage: ciImage, orientation:orientation)
                        let request = VNDetectFaceRectanglesRequest { (request, _) in
                            //print(request.results?.count)
                            if request.results!.count != 0{
                                let results = request.results as! [VNFaceObservation]
                                let firstObservation = results
                                
                                print(firstObservation)
                                for observation in firstObservation{
                                    let faceS = (observation.boundingBox.height*observation.boundingBox.width)
                                    
                                    if maxS < faceS{
                                        maxS = faceS
                                        maxindex = i
                                        
                                    }
                                    i+=1
                                      
                                }
                                if let drawn = self.drawFaceRectangle(image: uiimg, observation: firstObservation[maxindex]){
                                    uiimg = drawn
                                }
                                DispatchQueue.main.async {
                                    
                                    if index==assets.count-1{
                                        self.Obtn.isEnabled = true
                                    }
                                   
                                    self.imagelist.append(uiimg)
                                    
                                }
                                
                                
                            }
                        }
                        try? handler.perform([request])
                    }
                    
                    
                    
                    // ここで取り出せる
                    
                    self.imgview1.image = image
                    self.i+=1
                    
                    
                    
                    
                    
                    
                })
            }
        }
        self.present(pickerController, animated: true) {}
       
    }
    
    @IBAction func toLbtn(_ sender: Any) {
        self.performSegue(withIdentifier: "toL", sender: nil)
        print(imagelist.count)
        imagelist=[]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toL" {
                let nextview = segue.destination as! LViewController
                self.Obtn.isEnabled = false
                nextview.ilist = imagelist
            }
        }
    func drawFaceRectangle(image: UIImage?, observation: VNFaceObservation) -> UIImage?{
        let imageSize = image!.size
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        image?.draw(in: CGRect(origin: .zero, size: imageSize))
        context?.fill(observation.boundingBox.converted(to: imageSize))
        var cimg:CGImage = (image?.cgImage?.cropping(to: observation.boundingBox.converted(to: imageSize)))!
        let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return UIImage(cgImage: cimg)
    }
    
    func convertToArray(from mlMultiArray: MLMultiArray) -> [Double] {
        
        // Init our output array
        var array: [Double] = []
        
        // Get length
        let length = mlMultiArray.count
        
        // Set content of multi array to our out put array
        for i in 0...length - 1 {
            array.append(Double(truncating: mlMultiArray[[0,NSNumber(value: i)]]))
        }
        
        return array
    }
    
    
    
}



