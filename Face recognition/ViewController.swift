import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var Lbtn: UIButton!
    
   
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var Abtn: UIButton!
    @IBOutlet weak var Tbtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.img1.image = UIImage(named: "Timg")
        Lbtn.layer.cornerRadius=5
        Lbtn.layer.shadowOpacity=0.2
        Lbtn.layer.shadowRadius=3
        Lbtn.layer.shadowOffset=CGSize(width: 4, height: 4)
        
        Tbtn.layer.cornerRadius=5
        Tbtn.layer.shadowOpacity=0.2
        Tbtn.layer.shadowRadius=3
        Tbtn.layer.shadowOffset=CGSize(width: 4, height: 4)
        
        Abtn.layer.cornerRadius=5
        Abtn.layer.shadowOpacity=0.2
        Abtn.layer.shadowRadius=3
        Abtn.layer.shadowOffset=CGSize(width: 4, height: 4)
        
    }
    @IBAction func toL(_ sender: Any) {
        self.performSegue(withIdentifier: "toLcamera", sender: nil)
    }
    @IBAction func facebtn(_ sender: Any) {
        self.performSegue(withIdentifier: "tofacecamera", sender: nil)
    }
    @IBAction func toAttandance(_ sender: Any) {
        self.performSegue(withIdentifier: "toA", sender: nil)
    }
    @IBAction func reset(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "確認", message: "アプリを初期状態に戻してもよろしいですか？", preferredStyle:  UIAlertController.Style.alert)
        // 確定ボタンの処理
        let confirmAction: UIAlertAction = UIAlertAction(title: "リセット", style: UIAlertAction.Style.default, handler:{
            // 確定ボタンが押された時の処理をクロージャ実装する
            (action: UIAlertAction!) -> Void in
            //実際の処理
            let appDomain = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            
            
        
        })
        //UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
      
        //実際にAlertを表示する
        present(alert, animated: true, completion: nil)
        
    }
    
    // キャンセルボタンの処理
    let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
        // キャンセルボタンが押された時の処理をクロージャ実装する
        (action: UIAlertAction!) -> Void in
        //実際の処理
        print("キャンセル")
    })
}


