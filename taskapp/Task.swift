//
//  Task.swift
//  taskapp
//
//  Created by 井口創太 on 2021/02/21.
//

import RealmSwift

class Task: Object {
  //管理用ID　プライマリーキー
  @objc dynamic var id = 0
  
  //タイトル
  @objc dynamic var title = ""
  
  //内容
  @objc dynamic var contents = ""
  
  //日時
  @objc dynamic var date = Date()
  
  //カテゴリー
  @objc dynamic var category = ""
  
  //idをプライマリーキーとして設定
  override static func primaryKey() -> String? {
    return "id"
  }
}

class Category: Object {
  //管理用ID
  @objc dynamic var id = 0
  
  //カテゴリー
  @objc dynamic var category = ""
  
  override static func primaryKey() -> String? {
    return "id"
  }
}
