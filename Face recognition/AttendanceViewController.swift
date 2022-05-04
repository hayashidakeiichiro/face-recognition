//
//  AttendanceViewController.swift
//  Face recognition
//
//  Created by 林田計一郎 on 2022/04/22.
//

import UIKit

class AttendanceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    var attend:[String] = []
    var key:[String] = []
    @IBOutlet weak var appendname: UITextField!
    @IBOutlet weak var appendbtn: UIButton!
    
    @IBOutlet weak var Tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        appendname.delegate = self
        Tableview.dataSource = self
        Tableview.delegate = self
        if UserDefaults.standard.object(forKey: "Attendance") != nil{
            self.attend = UserDefaults.standard.array(forKey: "Attendance") as! [String]
        }
        if UserDefaults.standard.object(forKey: "key") != nil{
            self.key = UserDefaults.standard.array(forKey: "key") as! [String]
        }
        
        self.appendbtn.layer.cornerRadius=5
        self.appendbtn.layer.shadowOpacity=0.3
        self.appendbtn.layer.shadowRadius=3
        self.appendbtn.layer.shadowOffset=CGSize(width: 4, height: 4)
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          //テーブルを再描画
        if UserDefaults.standard.object(forKey: "Attendance") != nil{
            self.attend = UserDefaults.standard.array(forKey: "Attendance") as! [String]
        }
        if UserDefaults.standard.object(forKey: "key") != nil{
            self.key = UserDefaults.standard.array(forKey: "key") as! [String]
        }
          self.Tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attend.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Tableview.dequeueReusableCell(withIdentifier: "mytablecell", for: indexPath)
            
        cell.textLabel?.text = attend[indexPath.row]
       
        
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toedit" {
                let nextview = segue.destination as! EditlistViewController
                nextview.listname = sender as! String
            }
        }
  
    
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toedit",sender: attend[indexPath.row])
        Tableview.deselectRow(at: indexPath, animated: true)
        

    }
    
    @IBAction func Append(_ sender: Any) {
        if (!attend.contains(self.appendname.text!) && self.appendname.text! != ""){
            self.attend.append(self.appendname.text!)
            UserDefaults.standard.set(self.attend, forKey: "Attendance")
            let zipped = zip(self.key,Array(repeating: 0, count: self.key.count))
            let list:[String:Int] = Dictionary(uniqueKeysWithValues: zipped)
            UserDefaults.standard.set(self.attend, forKey: "Attendance")
            UserDefaults.standard.set(list, forKey: self.appendname.text!)
            
            // テーブルビューをリロードする
            self.Tableview.reloadData()
            self.appendname.text = ""
            
        }
        
    }
    @IBAction func returnButtonDidTapped(_ sender: Any) {
        }
        
    //textField以外の部分のタッチ時にキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            appendname.resignFirstResponder()
            return true
    }

}


