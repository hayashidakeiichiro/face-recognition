//
//  EditlistViewController.swift
//  Face recognition
//
//  Created by 林田計一郎 on 2022/04/22.
//

import UIKit

class EditlistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    var listname:String = ""
    var list:[String:Int] = ["0":1]
    var keys = ["0"]
    var names:[String] = []
    var selectedname = ""
    

    @IBOutlet weak var attend_num_label: UILabel!
    @IBOutlet weak var namepicker: UIPickerView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var name: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        
        namepicker.delegate = self
        namepicker.dataSource = self
        
        UINib(nibName: "UICollectionElementKindCell", bundle:nil)
        name.text = self.listname
        
        if UserDefaults.standard.object(forKey: self.listname) != nil{
            print(self.listname)
            self.list = UserDefaults.standard.dictionary(forKey: self.listname) as! [String:Int]
            self.keys = Array(self.list.keys)
        }
        if UserDefaults.standard.object(forKey: "key") != nil{
            print(self.listname)
            self.names = UserDefaults.standard.array(forKey: "key") as! [String]
        }
        
    
        for k in self.keys{
            if self.names.contains(k){
                self.names.removeAll(where: {$0 == k})
            }
            
        }
        self.attend_num_label.text = String(calcAttend(dict: self.list))+"/"+String(self.list.count)+"出席"
 
        
    }
    
    func calcAttend(dict: [String:Int]) -> Int{
        var num = 0
        for i in dict{
            if i.value != 0{
                num+=1
            }
        }
                    
        return num
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "mytablecell2", for: indexPath)
            
        var str = ""
        let label = cell.contentView.viewWithTag(1) as! UILabel
        let label2 = cell.contentView.viewWithTag(2) as! UILabel
        label.layer.cornerRadius = 10
        if list[keys[indexPath.row]] != 0{
            let tymeInterval = Double(list[keys[indexPath.row]]!)

            let date = Date(timeIntervalSince1970: tymeInterval)
            // フォーマット設定
            let df = DateFormatter()

            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            str = df.string(from: date)
            
            label.text = "出"
            cell.backgroundColor = UIColor(red: 150/255, green: 255/255, blue: 150/255, alpha: 1)
        }
        else if list[keys[indexPath.row]] == 0{
            label.text = "欠"
            cell.backgroundColor = UIColor(red: 255/255, green: 150/255, blue: 160/255, alpha: 1)
            
        }
        label2.text = str + "    "
        cell.textLabel?.text = keys[indexPath.row]
        cell.textLabel?.font = cell.textLabel?.font.withSize(20)
        self.attend_num_label.text = String(calcAttend(dict: self.list))+"/"+String(self.list.count)+"出席"
   
        
        return cell
    }
    
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        //アラート生成
        let name = self.keys[indexPath.row]
        //UIAlertControllerのスタイルがalert
        let alert: UIAlertController = UIAlertController(title: "確認", message:  name+"さんをイベントから\n削除してもよろしいですか？", preferredStyle:  UIAlertController.Style.alert)
        // 確定ボタンの処理
        let confirmAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default, handler:{
            // 確定ボタンが押された時の処理をクロージャ実装する
            (action: UIAlertAction!) -> Void in
            //実際の処理
            
            
            self.list.removeValue(forKey: name)
            self.names.append(name)
            self.keys = Array(self.list.keys)
            self.namepicker.reloadAllComponents()
            self.tableview.reloadData()
            
            UserDefaults.standard.set(self.list, forKey: self.listname)
            
        
        })
        //UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
      
        //実際にAlertを表示する
        present(alert, animated: true, completion: nil)
        tableview.deselectRow(at: indexPath, animated: true)
        
        
   
           
        }
    
    
    @IBAction func reset(_ sender: Any) {
        let zipped = zip(self.keys,Array(repeating: 0, count: self.keys.count))
        self.list = Dictionary(uniqueKeysWithValues: zipped)
        UserDefaults.standard.set(self.list, forKey: self.listname)
        self.tableview.reloadData()
    }
    
    
    
    // キャンセルボタンの処理
    let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
        // キャンセルボタンが押された時の処理をクロージャ実装する
        (action: UIAlertAction!) -> Void in
        //実際の処理
        print("キャンセル")
    })
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
     
    // UIPickerViewの行数、要素の全数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return names.count
    }
     
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        if names.count != 0{
            selectedname = names[row]
        }
        return names[row]
    }
     
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        // 処理
        if names.count != 0{
            selectedname = names[row]
        }
        
    }

    @IBAction func appendname(_ sender: Any) {
        if selectedname != ""{
            list.updateValue(0, forKey: selectedname)
            keys = Array(list.keys)
            UserDefaults.standard.set(list, forKey: listname)
            names.removeAll(where: { $0 == selectedname })
            
            
            namepicker.reloadAllComponents()
            tableview.reloadData()
            print(list,selectedname,keys)
            selectedname = ""
        }
        
        
    }
    
    //出欠簿を削除
    @IBAction func deleteall(_ sender: Any) {
        
        let alert: UIAlertController = UIAlertController(title: "確認", message:  listname+"を削除してもよろしいですか？", preferredStyle:  UIAlertController.Style.alert)
        // 確定ボタンの処理
        let confirmAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default, handler:{
            // 確定ボタンが押された時の処理をクロージャ実装する
            (action: UIAlertAction!) -> Void in
            //実際の処理
            var attend = UserDefaults.standard.array(forKey: "Attendance") as! [String]
            
            attend.removeAll(where: {$0==self.listname})
            UserDefaults.standard.removeObject(forKey: self.listname)
            UserDefaults.standard.set(attend, forKey: "Attendance")
            self.navigationController?.popViewController(animated: true)
            
        
        })
        //UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
      
        //実際にAlertを表示する
        present(alert, animated: true, completion: nil)
    }
    
}
