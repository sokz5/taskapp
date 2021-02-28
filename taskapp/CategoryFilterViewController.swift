//
//  CategoryFilterViewController.swift
//  taskapp
//
//  Created by 井口創太 on 2021/02/25.
//

import UIKit
import RealmSwift

class CategoryFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  
  var realm = try! Realm()
  var category: Category!
  var selectcategory: String? = ""
  
  var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.allowsMultipleSelectionDuringEditing = false
  }
  
  //tableviewを選択できるようにする
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    tableView.isEditing = editing
  }
  
  //cellの個数を返す
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categoryArray.count
  }
  
  //セルに表示する内容を設定
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //再利用可能なcellを得る
    let cell = tableView.dequeueReusableCell(withIdentifier: "CateCell", for: indexPath)
    
    //Cellに値を設定する
    let categorycell = categoryArray[indexPath.row]
    cell.textLabel?.text = categorycell.category
    cell.selectionStyle = .none
    
    return cell
  }
  
  //セルが選択された場合の動作
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //print("select - \(indexPath)")
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType = .checkmark
    selectcategory = cell?.textLabel?.text!
    print(selectcategory!)
  }
  
  //セル選択が解除されたときの動作
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    //print("deselect - \(indexPath)")
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType = .none
    selectcategory = ""
  }
  
  //カテゴリー絞り込みをするボタン　didselectRowでcellデータを取得し、データを渡す
  @IBAction func filtering(_ sender: Any) {
    //print(self.presentedViewController!)
    //let preVC = self.presentingViewController! as! ViewController
    //let preVC = preNC.viewControllers[preNC.viewControllers.count - 2] as! ViewController
    //let viewController: ViewController = self.storyboard?.instantiateViewController(withIdentifier: "viewcontroller") as! ViewController
    let viewController = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! ViewController
    self.navigationController?.popViewController(animated: true)
    
    viewController.filtercategory = selectcategory!
    
    //self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  //カテゴリー絞り込みをリセットするボタン(すべてのタスクを表示)
  @IBAction func resetfiltering(_ sender: Any) {
    let viewController = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! ViewController
    self.navigationController?.popViewController(animated: true)
    
    viewController.filtercategory = ""
    //self.navigationController?.pushViewController(viewController, animated: true)
  }
  
}
