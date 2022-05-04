//
//  Lcamera.swift
//  Face recognition
//
//  Created by 林田計一郎 on 2022/04/17.
//

import UIKit

import DKImagePickerController
import Vision

class Lcamera: UIViewController  , UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
   
    let noimg = UILabel()
    var imagelist:[UIImage]=[]
    var i = 0
    
    let screen_width = UIScreen.main.bounds.size.width
    @IBOutlet weak var Sbtn: UIButton!
    
    @IBOutlet weak var Obtn: UIButton!
   
    @IBOutlet weak var listview: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        
        self.noimg.frame = CGRect(x: 0, y: viewSize.height*0.3+30, width: viewSize.width, height: 60)
        self.noimg.text = "顔の写っている写真を選択してください"
        self.noimg.textAlignment = NSTextAlignment.center
        self.noimg.textColor = UIColor(cgColor: CGColor(gray: 0.3, alpha: 0.7))
        
        self.view.addSubview(self.noimg)
        self.listview.frame = CGRect(x: 0, y: 30, width: viewSize.width, height: viewSize.height*0.6)
        Sbtn.layer.cornerRadius=5
        Sbtn.layer.shadowOpacity=0.3
        Sbtn.layer.shadowRadius=3
        Sbtn.layer.shadowOffset=CGSize(width: 4, height: 4)
        
        Obtn.layer.cornerRadius=5
        Obtn.layer.shadowOpacity=0.3
        Obtn.layer.shadowRadius=3
        Obtn.layer.shadowOffset=CGSize(width: 4, height: 4)
        
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
                            let RESULT = request.results
                            
                            if RESULT != nil{
                                let results = request.results as! [VNFaceObservation]
                                let firstObservation = results
                                
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
                                    self.imagelist.append(uiimg)
                                    self.noimg.text = ""
                                    
                                    if index==assets.count-1{
                                        self.listview.reloadData()
                                        self.Obtn.isEnabled = true
                                    }
                                   
                                    
                                    
                                }
                                
                                
                            }
                        }
                        try? handler.perform([request])
                    }
                    
                    
                    
                    // ここで取り出せる
                 
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
        listview.reloadData()
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
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagelist.count
    }
    func collectionView(_ listview: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: (screen_width - 45)/5, height: (screen_width - 45)/5)
        }
 
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        //storyboard上のセルを生成　storyboardのIdentifierで付けたものをここで設定する
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Lcamera cell", for: indexPath)

      
        let imageview = cell.contentView.viewWithTag(1) as! UIImageView
        imageview.frame = CGRect(x:0, y:0, width: (screen_width - 45)/5, height: (screen_width - 45)/5)

      
        imageview.image = self.imagelist[indexPath.row]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)  {
        //アラート生成
        let index = indexPath.row
        //UIAlertControllerのスタイルがalert
        let alert: UIAlertController = UIAlertController(title: "確認", message:  "画像を削除してもよろしいですか？", preferredStyle:  UIAlertController.Style.alert)
        // 確定ボタンの処理
        let confirmAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default, handler:{
            // 確定ボタンが押された時の処理をクロージャ実装する
            (action: UIAlertAction!) -> Void in
            //実際の処理
            
            self.imagelist.remove(at: index)
            if self.imagelist.count == 0{
                self.noimg.text = "顔の写っている写真を選択してください"
                self.Obtn.isEnabled = false
            }
            
            self.listview.reloadData()
        })
        //UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        //実際にAlertを表示する
        present(alert, animated: true, completion: nil)
           
        }
    let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
        // キャンセルボタンが押された時の処理をクロージャ実装する
        (action: UIAlertAction!) -> Void in
        //実際の処理
        print("キャンセル")
    })
    
    
    
}



