//
//  ViewController.swift
//  SnackApp
//
//  Created by Kou on 2021/02/13.
//  Copyright © 2021 KouMitobe. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UISearchBarDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Search Barのdelegate通知先を設定
        searchText.delegate = self
        //プレースホルダーを設定
        searchText.placeholder = "お菓子の名前を入力してください"
    }

    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    //検索ボタンをクリック(タップ)時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        view.endEditing(true)
        //デバックエリアに出力
        if let searchWord = searchBar.text{
            print(searchWord)
        }
        
    }
}
