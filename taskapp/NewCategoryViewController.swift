//
//  NewCategoryViewController.swift
//  taskapp
//
//  Created by 井口創太 on 2021/02/22.
//

import UIKit
import RealmSwift

class NewCategoryViewController: UIViewController, UITextFieldDelegate{

  @IBOutlet weak var newCategory: UITextField!
  @IBOutlet weak var categorySave: UIBarButtonItem!
  
  let realm = try! Realm()
  var category:Category!
  var alertController: UIAlertController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    newCategory.delegate = self
    categorySave.isEnabled = false
    
    //背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
    let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    self.view.addGestureRecognizer(tapGesture)
    newCategory.text = category.category
  }
  
  //カテゴリー名が入力されているときだけ保存可能
  @IBAction func checkCategoryName(_ sender: Any) {
    if newCategory.text == "" {
      categorySave.isEnabled = false
    } else {
      categorySave.isEnabled = true
    }
  }
  
  //alear作成関数
  func alert(title:String, message:String) {
    alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alertController, animated: true)
  }
  
  //カテゴリー名保存ボタン処理 同じ名前を禁止する
  @IBAction func categorySave(_ sender: Any) {
    let result = realm.objects(Category.self).filter("category == '\(newCategory.text!)'")
    let count = result.count
    
    if count == 1 {
      alert(title: "エラー", message: "既に入力されたカテゴリー名は存在しています\n入力し直してください")
      newCategory.text! = ""
    } else {
    try! realm.write {
      self.category.category = self.newCategory.text!
      self.realm.add(self.category ,update: .modified)
    }
      //print(realm.objects(Category.self))
      
      self.navigationController?.popViewController(animated: true)}
  }
  
  //キャンセルボタンの処理
  @IBAction func categoryCancel(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  //キーボードを閉じる
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
  
}
