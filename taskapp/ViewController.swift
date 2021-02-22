//
//  ViewController.swift
//  taskapp
//
//  Created by 井口創太 on 2021/02/19.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

  @IBOutlet weak var tableView: UITableView!
  
  //Realmインスタンスを取得する
  let realm = try! Realm()
  var task: Task!
  
  let searchBar = UISearchBar()
  var cancel_result: Results<Task>?
  
  //DB内のタスクが格納されるリスト
  //日付の近い順でソート:昇順
  //以降内容をアップデートするとリスト内は自動的に更新される
  var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    cancel_result = taskArray
    
    tableView.delegate = self
    tableView.dataSource = self
    
    searchBar.placeholder = "検索"
    searchBar.delegate = self
    //searchBar.showsCancelButton = true
    searchBar.enablesReturnKeyAutomatically = false
    //searchBar.scopeButtonTitles = ["全体", "カテゴリー"]
    //earchBar.showsCancelButton = true
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  //sectionを使うときのメソッド
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return ""
  }
  
  //sectionにsearchBarを設置
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return searchBar
  }
  
  //searchBarの高さを設定
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 44
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func searchItems(searchText: String) {
    guard let searchText = searchBar.text else {return}
    
    let result = realm.objects(Task.self).filter("category BEGINSWITH '\(searchText)'")
    let count = result.count
    
    if (count == 0) {
      taskArray = realm.objects(Task.self)
    } else {
      taskArray = result
    }
    tableView.reloadData()
  }
  
  //検索ボタンを押したときのメソッド
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    searchItems(searchText: searchBar.text! as String)
  }
  
  //searchBarのテキストが変更されるごとに呼び出される
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchItems(searchText: searchText)
  }
  
  /*
  //キャンセルボタンを押したときのメソッド
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    searchBar.endEditing(true)
    taskArray = cancel_result!
    tableView.reloadData()
  }
  */
  
  //データの数を返すメソッド
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return taskArray.count
  }
  
  //各セルの内容を返すメソッド
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //再利用可能なcellを得る
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    //Cellに値を設定する
    let task = taskArray[indexPath.row]
    cell.textLabel?.text = task.title
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    let dateString:String = formatter.string(from: task.date)
    cell.detailTextLabel?.text = dateString
    
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
    if editingStyle == .delete {
      //削除するタスクを取得する
      let task = self.taskArray[indexPath.row]
      
      //ローカル通知をキャンセルする
      let center = UNUserNotificationCenter.current()
      center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
      
      //データベースから削除する
      try! realm.write {
        self.realm.delete(self.taskArray[indexPath.row])
        tableView.deleteRows(at: [indexPath], with: .fade)
      }
      
      //未通知のローカル通知一覧をログ出力
      center.getPendingNotificationRequests{(requests: [UNNotificationRequest]) in
        for request in requests {
          print("/---------------")
          print(request)
          print("---------------/")
        }
      }
    }
  }
  
  //segueで画面遷移するときに呼ばれる
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let inputViewController:InputViewController = segue.destination as! InputViewController
    if segue.identifier == "cellSegue" {
      let indexPath = self.tableView.indexPathForSelectedRow
      inputViewController.task = taskArray[indexPath!.row]
    } else {
      let task = Task()
      let allTasks = realm.objects(Task.self)
      if allTasks.count != 0 {
        task.id = allTasks.max(ofProperty: "id")! + 1
      }
      inputViewController.task = task
    }
  }
  
  //入力画面から戻ってきたときにTableViewを更新させる
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
}

