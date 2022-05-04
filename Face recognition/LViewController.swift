//
//  LViewController.swift
//  Face recognition
//
//  Created by 林田計一郎 on 2022/04/17.
//
//
//  LViewController.swift
//  Anomaly detection
//
//  Created by 林田計一郎 on 2022/04/14.
//
import Vision
import UIKit

class LViewController: UIViewController , UITextFieldDelegate {
    
    @IBOutlet weak var faceimg: UIImageView!
    
    
    var ilist:[UIImage]!
    var result:[[Double]]=[]
    @IBOutlet weak var trainbtn: UIButton!
    
    @IBOutlet weak var textlabel: UITextField!

    var screen_width = UIScreen.main.bounds.size.width
    var screen_height = UIScreen.main.bounds.size.height
    var label_name:String?
    var key:[String]=[]
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINib(nibName: "UICollectionElementKindCell", bundle:nil)
        let viewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        
        self.trainbtn.isEnabled = false
        self.trainbtn.layer.cornerRadius=5
        self.trainbtn.layer.shadowOpacity=0.3
        self.trainbtn.layer.shadowRadius=3
        self.trainbtn.layer.shadowOffset=CGSize(width: 4, height: 4)
        self.trainbtn.frame = CGRect(x: viewSize.width*0.5-150, y: viewSize.height*0.8-100, width: 300, height: 150)
        self.trainbtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.faceimg.frame = CGRect(x: viewSize.width*0.5-80, y: 100, width: 160, height: 160)
        try? self.faceimg.image = ilist[0]
       
        textlabel.delegate = self
        if UserDefaults.standard.object(forKey: "key") != nil{
            self.key = UserDefaults.standard.array(forKey: "key") as! [String]
        }
        
        
        
        
        //推論
        let model = try? VNCoreMLModel(for: test2().model)
        let request2 = VNCoreMLRequest(model: model!, completionHandler: {
            (finishReq, err) in
//            print(finishReq.results)
            
            let results = finishReq.results as? [VNCoreMLFeatureValueObservation]
            
          
            let firstObservation = results?.first
           
            let m: MLMultiArray = (firstObservation?.featureValue.multiArrayValue!)!
            let ans = self.convertToArray(from: m)
           
            //let sorted = dic.sorted(by: {$0.1>$1.1})
          
           
            // 識別結果と確率を表示する
            DispatchQueue.main.async {
  
                self.result.append([])
                self.result[self.result.endIndex-1].append(contentsOf: ans)
                
                
            }
            
        })
       
        for i in 0..<self.ilist.count{
            
            try? VNImageRequestHandler(cgImage: self.ilist[i].cgImage!, options: [:]).perform([request2])
            
            
       }
       
        
    }
    
    
    @IBAction func inputlabel(_ sender: UITextField) {
        self.label_name = self.textlabel.text!
        self.validate()
        
    }
    private func validate() {
              
          // nilの場合はtourokuButtonを非活性に
        guard let text:String = self.label_name else {
                  
            self.trainbtn.isEnabled = false
            
            return
                    
          }
        self.trainbtn.setTitle("登録", for: .normal)
          // 文字数が0の場合(""空文字)tourokuButtonを非活性に
        if text.count == 0 {
            
              self.trainbtn.isEnabled = false
              return
            
          }
        if key.contains(text){
            self.trainbtn.isEnabled = false
            self.trainbtn.setTitle("登録済みの名前です", for: .normal)
            self.trainbtn.titleLabel?.font = .systemFont(ofSize: 30.0, weight: .bold)
           
            return
        }
          
          // nilでないかつ0文字以上はtourokuButtonを活性に
          self.trainbtn.isEnabled = true
        
    }
    
    
    @IBAction func train(_ sender: Any) {
        let resultT = self.result.transpose()
        
        
        var Feature:[Double] = []
        for i in 0 ..< resultT.count{
            let m = Int(resultT[i].count/2)
            let sorted = resultT[i].sorted(by: {$0>$1})
            Feature.append(sorted[m])
            if i == resultT.count-1{
                self.key.append(textlabel.text!)
                UserDefaults.standard.set(Feature, forKey: textlabel.text!)
                UserDefaults.standard.set(self.key, forKey: "key")
                
            }
            
        }
       
        
        self.trainbtn.setTitle("登録完了", for: .normal)
        self.trainbtn.isEnabled = false
        self.trainbtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.navigationController?.popToRootViewController(animated: true)
            
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
    
    
    
    
   
    @IBAction func returnButtonDidTapped(_ sender: Any) {
        }
        
    //textField以外の部分のタッチ時にキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textlabel.resignFirstResponder()
            return true
    }
}
extension Array where Element: RandomAccessCollection, Element.Index == Int {
    func transpose() -> [[Element.Element]] {
        return self.isEmpty ? [] : (0...(self.first!.endIndex - 1)).map { i -> [Element.Element] in self.map { $0[i] } }
    }
}



