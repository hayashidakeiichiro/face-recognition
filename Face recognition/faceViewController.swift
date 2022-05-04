//
//  faceViewController.swift
//  Face recognition
//
//  Created by 林田計一郎 on 2022/04/17.
//

//
//  Tcamera.swift
//  Anomaly detection
//
//  Created by 林田計一郎 on 2022/04/14.
//

import UIKit
import AVKit
import VideoToolbox
import Vision

class faceViewController: UIViewController  , AVCaptureVideoDataOutputSampleBufferDelegate, UIPickerViewDelegate,UIPickerViewDataSource{
    
  
    @IBOutlet weak var Threshold: UISlider!
  
    @IBOutlet weak var selectlist: UITextField!
    var Feature:[Double] = []
    var key:[String] = []
    var list:[String:Int] = [:]
    
    var pickerview: UIPickerView = UIPickerView()
    var colorchange = 0
    var counter = 0
    var tonextimg:UIImage = UIImage(named: "frame")!
  
    
    var viewSize:CGSize = CGSize(width: 0, height: 0)
    var imageView:UIImageView = UIImageView(image: UIImage(named: "frame"))
    var inoutn = 0
    let capureSession = AVCaptureSession()
    var attend:[String] = ["No Data"]
    var selectedivent:String = ""
    
    var pre_ans:String = ""
    var cont = 0
    
    @IBOutlet weak var inoutbtn: UIButton!
    @IBOutlet weak var rlabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerview.delegate = self
        pickerview.dataSource = self
        self.selectlist.inputView = pickerview
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        self.selectlist.inputAccessoryView = toolbar
        
        
        //print(Feature)
        self.viewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height*0.6)
        
        let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video,position: .front)
        //self.imageView.backgroundColor = UIColor(red: 100, green: 100, blue: 100, alpha: 100)
      
        let input = try? AVCaptureDeviceInput(device: captureDevice!)
        
        if UserDefaults.standard.object(forKey: "Attendance") != nil{
            self.attend = UserDefaults.standard.array(forKey: "Attendance") as! [String]
        }
        
        self.imageView.image = UIImage(named: "frame.png")
        
        
        
        // セッションを開始する
     
        self.capureSession.addInput(input!)
        self.capureSession.startRunning()
        
        //ビデオのプレビューをビューに表示するようにする
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.capureSession)
        let pvSize = self.view.frame.width
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        previewLayer.frame = CGRect(x: 0, y: 150, width: pvSize, height: self.view.frame.height*0.6)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        self.capureSession.addOutput(dataOutput)
        self.imageView.frame = CGRect(x: 0, y: 300, width: 100, height: 100)
        
        
        
        self.view.addSubview(self.imageView)
        self.inoutbtn.frame = CGRect(x: self.viewSize.width-30, y: self.viewSize.height-30+150, width: 20, height: 20)
        self.view.addSubview(self.inoutbtn)
        
        self.rlabel.frame = CGRect(x: 0, y: self.viewSize.height+180, width: self.viewSize.width, height: 100)
        self.selectlist.frame = CGRect(x: 0, y: self.viewSize.height+150, width: self.viewSize.width, height: 80)
        /*
        let img2:UIImageView = UIImageView(image: UIImage(named: "face"))
        img2.frame = CGRect(x: 0, y: 150, width: pvSize, height: self.view.frame.height*0.6)
        self.view.addSubview(img2)
         */

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.capureSession.inputs.forEach { input in
                    self.capureSession.removeInput(input)
                }
                self.capureSession.outputs.forEach { output in
                    self.capureSession.removeOutput(output)
                }
        var captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video,position: .back)
        
        if self.inoutn == 0{
            captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video,position: .front)
            
        }
    
      
        let input = try? AVCaptureDeviceInput(device: captureDevice!)

        
        // セッションを開始する
     
        self.capureSession.addInput(input!)
        self.capureSession.startRunning()
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        self.capureSession.addOutput(dataOutput)
         
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        var inpimg:CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &inpimg)
        
        var uiimg = UIImage(cgImage: inpimg!).rotatedBy(degree: 90)
        let uiimg2=uiimg
        let inpimg2 = uiimg.cgImage
        var classification:[String:Double] = [:]
        var ans:String = "error"
        let model = try? VNCoreMLModel(for: test2().model)
        
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
               
                if ansVal < Double(1-self.Threshold.value)*1000{
                    self.rlabel.text=String(ans)
                    if self.list[ans] != nil{
                        
                        if self.list[ans] == 0{
                            if self.cont>10{
                                
                                //ここで出席になる
                                
                                let now = Date()
                                let timeInterval = now.timeIntervalSince1970
                                self.list[ans] = Int(timeInterval)
                                UserDefaults.standard.set(self.list, forKey: self.selectlist.text!)
                                self.cont = 0
                                self.colorchange = 1
                            
                            }
                            else{
                                if ans == self.pre_ans{
                                    self.cont += 1
                                }
                                else{
                                    self.pre_ans = ans
                                    self.cont = 0
                                }
                                
                                
                            }
                        }
                        else {
                            self.rlabel.text = ans+" 出席済"
                            
                            self.cont = 0
                            }
                            
                            
                        }
                        
                            
                    }
                else{
                    self.rlabel.text="登録されてない顔です"
                    self.cont = 0
                    self.pre_ans = ""
                    self.view.backgroundColor = UIColor.systemGray6
                }
                if self.colorchange >= 1{
                    self.view.backgroundColor = UIColor(red: 150/255, green: 255/255, blue: 150/255, alpha: 1)
                    self.colorchange += 1
                    if self.colorchange > 30{
                        self.colorchange = 0
                        self.view.backgroundColor = UIColor.systemGray6
                    }
                    
                }
          
            }
        })
        
        
          
        
        let ciImage = CIImage(image: uiimg)!
        var i = 0
        var maxS:Double = 0
        var maxindex = 0
        if let orientation = CGImagePropertyOrientation(rawValue: UInt32(uiimg.imageOrientation.rawValue)) {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation:orientation)
            let request = VNDetectFaceRectanglesRequest { [self] (request, _) in
                //print(request.results?.count ?? "0")
                if request.results?.count != 0{
                    
                    let results = request.results as! [VNFaceObservation]
                    let firstObservation = results
                    
                    //print(firstObservation!)
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
                        if self.imageView.image == nil{
                            self.imageView.image=UIImage(named: "frame")
                            
                            
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                    
                       
                    }
                    
                    try? VNImageRequestHandler(cgImage: uiimg.cgImage!, options: [:]).perform([request2])
                }
                else{
                    DispatchQueue.main.async {
                        self.imageView.image=nil
                        self.rlabel.text="顔を近づけてください"
                       
                    }
                    
                }
            }
            try? handler.perform([request])
      
        }
       
    }
    func drawFaceRectangle(image: UIImage?, observation: VNFaceObservation) -> UIImage?{
        
        let boundframe:CGRect = observation.boundingBox
        
        let imageSize = image!.size
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        image?.draw(in: CGRect(origin: .zero, size: imageSize))
        context?.fill(observation.boundingBox.converted(to: imageSize))
        var cimg:CGImage = (image?.cgImage?.cropping(to: observation.boundingBox.converted(to: imageSize)))!
        let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        DispatchQueue.main.async {
            if self.inoutn == 0{
                self.imageView.frame = CGRect(x:self.viewSize.width*(1-(boundframe.maxX-0.5)*192/108-0.5),
                                              y: ((1 - boundframe.maxY-0.5)*108/130+0.5) * self.viewSize.height+150,
                                          width: self.viewSize.width * boundframe.width*192/108 ,
                                              height: self.viewSize.height * boundframe.height*108/130)}
            else{
                self.imageView.frame = CGRect(x:self.viewSize.width*(0.5+(boundframe.minX-0.5)*192/108),
                                          y: ((1 - boundframe.maxY-0.5)*108/130+0.5) * self.viewSize.height+150,
                                          width: self.viewSize.width * boundframe.width*192/108 ,
                                              height: self.viewSize.height * boundframe.height*108/130)}
                
        }
        
        
        
        
        return UIImage(cgImage: cimg)
    }
    
    @IBAction func `inout`(_ sender: Any) {
        self.capureSession.stopRunning()
        self.capureSession.inputs.forEach { input in
                    self.capureSession.removeInput(input)
                }
                self.capureSession.outputs.forEach { output in
                    self.capureSession.removeOutput(output)
                }
        var captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video,position: .back)
        
        if self.inoutn == 0{
            captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video,position: .back)
            self.inoutn = 1
            
        }
        else{
            captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video,position: .front)
            self.inoutn = 0
        }
      
        let input = try? AVCaptureDeviceInput(device: captureDevice!)

        
        // セッションを開始する
     
        self.capureSession.addInput(input!)
        self.capureSession.startRunning()
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        self.capureSession.addOutput(dataOutput)
        
        
        
        
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
    
    //pickerview
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return attend.count
    }
    func pickerView(_ pickerView: UIPickerView,
                        titleForRow row: Int,
                        forComponent component: Int) -> String? {
        self.selectlist.text = attend[row]
        self.selectedivent = attend[row]
        self.list = UserDefaults.standard.dictionary(forKey:attend[row]) as! [String:Int]
        self.key = Array(self.list.keys)
        
        return attend[row]
        }
        
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
       
        self.selectlist.text = attend[row]
        self.list = UserDefaults.standard.dictionary(forKey:attend[row]) as! [String:Int]
        self.key = Array(self.list.keys)
    }
    @objc func cancel() {
        self.selectlist.text = ""
        self.selectlist.endEditing(true)
        
    }

    @objc func done() {
        self.selectlist.endEditing(true)
        
        
    }
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
            return CGRect(x: x, y: y, width: width, height: height)
    }
    
}
    


extension UIImage {

    func rotatedBy(degree: CGFloat) -> UIImage {
        let radian = -degree * CGFloat.pi / 180
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: self.size.width / 2, y: self.size.height / 2)
        context.scaleBy(x: 1.0, y: -1.0)

        context.rotate(by: radian)
        context.draw(self.cgImage!, in: CGRect(x: -(self.size.width / 2), y: -(self.size.height / 2), width: self.size.width, height: self.size.height))

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return rotatedImage
    }

}

extension CGRect {
    func converted(to size: CGSize) -> CGRect {
        return CGRect(x: self.minX * size.width,
                      y: (1 - self.maxY) * size.height,
                      width: self.width * size.width,
                      height: self.height * size.height)
    }
}

extension UIImage {
    // resize image
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }

    // scale the image at rates
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}




