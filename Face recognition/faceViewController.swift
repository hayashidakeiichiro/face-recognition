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

class faceViewController: UIViewController  , AVCaptureVideoDataOutputSampleBufferDelegate{
  
    @IBOutlet weak var Threshold: UISlider!
  
    var Feature:[Double] = []
    var key:[String] = []
    
    
    @IBOutlet weak var img1: UIImageView!
    
    var viewSize:CGSize = CGSize(width: 0, height: 0)
    var imageView:UIImageView = UIImageView(image: UIImage(named: "frame"))
    var inoutn = 0
    let capureSession = AVCaptureSession()
    
    @IBOutlet weak var rlabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //print(Feature)
        self.viewSize = CGSize(width: self.view.frame.width, height: self.view.frame.width)
        
        let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video,position: .front)
        
      
        let input = try? AVCaptureDeviceInput(device: captureDevice!)
        
        
        if UserDefaults.standard.object(forKey: "key") != nil{
            self.key = UserDefaults.standard.array(forKey: "key") as! [String]
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
        previewLayer.frame = CGRect(x: 0, y: 0, width: pvSize, height: pvSize)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        self.capureSession.addOutput(dataOutput)
        self.imageView.frame = CGRect(x: 0, y: 300, width: 100, height: 100)
        //self.imageView.backgroundColor = UIColor(red: 200, green: 200, blue: 200, alpha: 200)
        self.view.addSubview(self.imageView)

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
           
            // 識別結果と確率を表示する
            DispatchQueue.main.async {
                self.img1.image=uiimg
                //self.rlabel.text=String(ans)
                
                if ansVal < Double(1-self.Threshold.value)*1000{
                    self.rlabel.text=String(ans)}
                else{
                    self.rlabel.text="判別不可"
                }
          
            }
        })
        
        
          
        
        let ciImage = CIImage(image: uiimg)!
        var i = 0
        var maxS:Double = 0
        var maxindex = 0
        if let orientation = CGImagePropertyOrientation(rawValue: UInt32(uiimg.imageOrientation.rawValue)) {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation:orientation)
            let request = VNDetectFaceRectanglesRequest { (request, _) in
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
                        //self.img1.image=uiimg
                    }
                    try? VNImageRequestHandler(cgImage: uiimg.cgImage!, options: [:]).perform([request2])
                  
                    
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
        print(boundframe)
        DispatchQueue.main.async {
            if self.inoutn == 0{
                self.imageView.frame = CGRect(x: self.viewSize.width*(1-(boundframe.maxX-0.5)*192/108-0.5),
                                          y: (1 - boundframe.maxY) * self.viewSize.width,
                                          width: self.viewSize.width * boundframe.width*192/108 ,
                                              height: self.viewSize.width * boundframe.height)}
            else{
                self.imageView.frame = CGRect(x: self.viewSize.width*(0.5+(boundframe.minX-0.5)*192/108),
                                          y: (1 - boundframe.maxY) * self.viewSize.width,
                                          width: self.viewSize.width * boundframe.width*192/108 ,
                                              height: self.viewSize.width * boundframe.height)}
                
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




