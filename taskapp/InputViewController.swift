//
//  InputViewController.swift
//  taskapp
//
//  Created by 井口創太 on 2021/02/21.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var contentsTextView: UITextView!
  @IBOutlet weak var categoryTextField: UITextField!
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var taskSave: UIBarButtonItem!
  
  let realm = try! Realm()
  var task:Task?
  var pickerView = UIPickerView()
  var category:Category!
  var categorylist: Results<Category>?
  var selectCategory: Category?
  var categoryID: Int = 0
  var none_category: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    titleTextField.delegate = self

    //背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
    let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    self.view.addGestureRecognizer(tapGesture)
    titleTextField.text = task!.title
    contentsTextView.text = task!.contents
    datePicker.date = task!.date
    categoryTextField.text = task!.category?.category
    selectCategory = task!.category

    categorylist = realm.objects(Category.self)
    createPickerView()
    
    if none_category == true {
      setPicker()
    }
  }
  
  //pickerview初期値
  func setPicker() {
    pickerView.dataSource = self
    pickerView.delegate = self
    selectCategory = categorylist![0]
    categoryTextField.text = "指定なし"
    none_category = false
  }
  
  //PickerViewを追加
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  //PickerViewの表示データ
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return categorylist?.count ?? 0
  }
  
  //PicekerViewを作成して表示、キーボードが出てくるところにPickerViewを表示
  func createPickerView() {
    pickerView.delegate = self
    categoryTextField.inputView = pickerView
    //ツールバーを設定
    let toolbar = UIToolbar()
    toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width ,height: 44)
    let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    toolbar.setItems([space, doneButtonItem], animated: true)
    categoryTextField.inputAccessoryView = toolbar
  }
  
  //PickerViewで選択し終えたとき
  @objc func donePicker() {
    categoryTextField.endEditing(true)
  }
  
  //toolbar上のボタンを押すか、キーボード以外の場所をタップしたときにキーボード非表示
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    categoryTextField.endEditing(true)
  }
  
  //PickerViewを設定するデータを登録
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return categorylist?[row].category ?? ""
  }
  
  //PickerViewの各種データを選択したときに呼ばれるメソッド
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectCategory = categorylist?[row]
    print(selectCategory!)
    categoryTextField.text = categorylist?[row].category
    //categoryID = categorylist![row].id
  }
  
  //保存ボタンの有効無効判断
  override func viewWillAppear(_ animated: Bool) {
    if titleTextField.text == "" {
      taskSave.isEnabled = false
    }
  }
  
  //タイトルの入力状況に応じて保存ボタンの有効/無効を判断
  @IBAction func checkTitle(_ sender: Any) {
    if titleTextField.text == "" {
      taskSave.isEnabled = false
    } else {
      taskSave.isEnabled = true
    }
  }
  
  //保存ボタンの処理
  @IBAction func taskSave(_ sender: Any) {
    try! realm.write {
      self.task!.title = self.titleTextField.text!
      self.task!.contents = self.contentsTextView.text
      self.task!.date = self.datePicker.date
      //self.task.category = self.categoryTextField.text!
      //self.task!.category?.id = self.categoryID
      //self.task!.category?.category = self.categoryTextField.text!
      self.task!.category = self.selectCategory
      
      self.realm.add(self.task!, update: .modified)
    }
    setNotification(task: task!)
    //super.viewWillAppear(animated)
    self.navigationController?.popViewController(animated: true)
  }
  
  //キャンセルボタンの処理
  @IBAction func taskCancel(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  //通知設定する関数
  func setNotification(task: Task) {
    let content = UNMutableNotificationContent()
    //タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(✗✗なし)」を表示する)
    if task.title == "" {
      content.title = "(タイトルなし)"
    } else {
      content.title = task.title
    }
    if task.contents == "" {
      content.body = "(内容なし)"
    } else {
      content.body = task.contents
    }
    content.sound = UNNotificationSound.default
    
    //ローカル通知が発動するtrigger(日付マッチ)を作成
    let calender = Calendar.current
    let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
    //identifier, content, triggerからローカル通知を作成(identifierが同じだとローカル通知を上書き保存)
    let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
    
    //ローカル通知を登録
    let center = UNUserNotificationCenter.current()
    center.add(request) {
      (error) in print(error ?? "ローカル通知登録 OK")
    //error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
    }
    
    //未通知のローカル通知一覧をログ出力
    center.getPendingNotificationRequests{(requests: [UNNotificationRequest]) in
      for request in requests {
        print("/--------------")
        print(request)
        print("--------------/")
      }
    }
  }
  
  //キーボードを閉じる関数
  @objc func dismissKeyboard(){
    //キーボードを閉じる
    view.endEditing(true)
  }
  
  //カテゴリー新規作成画面に渡すデータ
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let newcategoryViewController:NewCategoryViewController = segue.destination as! NewCategoryViewController
    let category = Category()
    let allcategory = realm.objects(Category.self)
    if allcategory.count != 0 {
        category.id = allcategory.max(ofProperty: "id")! + 1
    }
    newcategoryViewController.category = category
  }
}
