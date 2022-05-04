//
//  recognitionViewController.swift
//  Face recognition
//
//  Created by 林田計一郎 on 2022/04/28.
//

import UIKit
import Vision

class recognitionViewController: UIViewController {
    var getimg:UIImage = UIImage(named: "frame")!
    
    var key:[String] = []
    var attend:[String] = ["No Data"]
    var list:[String:Int] = [:]
    var selectedivent:String = ""
    let Threshold = 0.5
    @IBOutlet weak var getimgview: UIImageView!
    
    @IBOutlet weak var recname: UILabel!
    
    
    override func viewDidLoad() {
        UINib(nibName: "UICollectionElementKindCell", bundle:nil)
        super.viewDidLoad()
        print(self.key,self.attend,self.selectedivent,self.list)
        self.getimgview.image = self.getimg
        let model = try? VNCoreMLModel(for: facenet().model)
        
        var uiimg = self.getimg.rotatedBy(degree: 90)
        let inpimg2 = uiimg.cgImage
        var classification:[String:Double] = [:]
        var ans:String = "error"
        
        let request2 = VNCoreMLRequest(model: model!, completionHandler: {
            (finishReq, err) in
//            print(finishReq.results)
            
            let results = finishReq.results as? [VNCoreMLFeatureValueObservation]
            let firstObservation = results?.first
            let m: MLMultiArray = (firstObservation?.featureValue.multiArrayValue!)!
            let a0 = self.convertToArray(from: m)
            var ansVal:Double = 1000
            
            
            for i in self.key{
                let Feature = UserDefaults.standard.array(forKey: i) as! [Double]
                let a1 = zip(Feature,a0).map(-)
                let a2 = zip(a1,a1).map(*)
                let a3 = a2.reduce(0,+)
                classification.updateValue(a3, forKey: i)
                
            }
            if let minVal1 = classification.min(by: { a, b in a.value < b.value }) {
                
                ans = minVal1.key
                ansVal = minVal1.value
            }
           
            // 識別結果を表示する
            DispatchQueue.main.async {
                self.recname.text = ans
                print(ans)
               
                if ansVal < Double(1-self.Threshold)*1000{
                    if self.list[ans] != nil{
                        
                        
                        if self.list[ans] == 0{
                            
                            self.list[ans] = 1
                            UserDefaults.standard.set(self.list, forKey: self.selectedivent)
                         
                        }
                   
                            
                    }
    
          
            }
        }
    })
    try? VNImageRequestHandler(cgImage: uiimg.cgImage!, options: [:]).perform([request2])
        
        
          
        
        

        // Do any additional setup after loading the view.
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
