//
//  ViewController.swift
//  taskapp
//
//  Created by 井口創太 on 2021/02/19.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  //データの数を返すメソッド
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  //各セルの内容を返すメソッド
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    return cell
  }
  
  //各セルを選択したときに実行されるメソッド
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "cellSegue", sender: nil)
  }
  
  //セルが削除可能なことを伝えるメソッド
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .delete
  }
  
  //Deleteボタンが押されたときに呼ばれるメソッド
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
  }
  
}

