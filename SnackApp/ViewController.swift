//
//  ViewController.swift
//  SnackApp
//
//  Created by Kou on 2021/02/13.
//  Copyright © 2021 KouMitobe. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UISearchBarDelegate ,UITableViewDataSource{

    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Search Barのdelegate通知先を設定
        searchText.delegate = self
        //プレースホルダーを設定
        searchText.placeholder = "お菓子の名前を入力してください"
        //TableViewのdataSource
        tableView.dataSource = self
        
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
        searchOkashi(keyword: searchWord)
        }
        
        
    }
    //お菓子の配列中にタプルを用意（オプショナル）
    //タプルは要素の中身を変更できない
    //タプルを配列で持っておけばレコードごとに格納できる
    var okashiList:[(name:String,maker:String,link:URL,image:URL)]? = []
    
    //searchOkashiメソッド
    //第一引数：keyword　検索したいワード
    func searchOkashi(keyword:String){
        //お菓子の検索キーワードをURLエンコードする
        //guard文を使ってエンコードnilになり得る変数、オプショナル変数を安全に参照するためのguard文でアンラップする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        //リクエストURL
        guard let req_url = URL(string: "https://sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r") else {
            return
        }
        //リクエストのURLをデバックエリアに出力
        print(req_url)
        //リクエストの処理
        //リクエストに必要な情報を生成(リクエストURLを使ってリクエストオブジェクトを生成)
        let req = URLRequest(url: req_url)
        //リクエストURLからリクエストを管理する為の、req（リクエストオブジェクトを生成しています）
        //第一引数：セッション構成 デフォルト
        //第二引数：デリゲート先 今回はクロージャで行う為nil
        //第三引数：デリゲートキューの設定
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        //リクエストをタスクとして登録
        //第一引数：リクエストを管理するオブジェクト
        //第二引数：クロージャ ダウンロードが完了するとcompletionHandlerが実行される
        let task = session.dataTask(with: req, completionHandler:{(data,response,error)in
            //セッションを終了
            session.finishTasksAndInvalidate()
            //do try catchエラーハンドリング
            do{
                //JSONDecoderインスタンス
                let decoder = JSONDecoder()
                let json = try decoder.decode(ResultJson.self,from: data!)
                //print(json)
                //jsonが取得できているかを確認
                if let items = json.item{
                    //お菓子のリストを初期化する
                    self.okashiList?.removeAll()
                    //取得したアイテム分ループする
                    for item in items{
                        //アイテムを各変数にアンラップする
                        if let name = item.name,let maker = item.maker,let link = item.url,let image = item.image {
                            //タプル配列に格納する
                            let okashi = (name ,maker ,link ,image)
                            self.okashiList?.append(okashi)
                        }
                        //TableViewを更新する
                        self.tableView.reloadData()
                        //デバック用に出力する
                        print("---------------")
                        self.okashiList?.forEach {print("\($0)")}
                    }
                }
            }catch{
                //エラー検知
                print("エラーが発生しました")
            }
        })
        //ダウンロード開始
        task.resume()
        
        
    }
    //レスポンス格納用の構造体全ての要素ごとにnilの可能性もあるので、オプショナル型で宣言
    struct ItemJson: Codable {
        //お菓子の名称
        let name:String?
        //メーカー
        let maker:String?
        //掲載URL
        let url:URL?
        //画像URL
        let image:URL?
    }
    //構造体をさらに配列で管理する為の構造体を作る
    struct ResultJson: Codable {
        //複数要素nilの可能性もある為オプショナル型で宣言
        let item:[ItemJson]?
    }
    //cellの総数を返すメソッド必ず記述する必要がある
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return okashiList?.count ?? 0
    }
    //cellに値を設定するdatasourceメソッド。必ず記述する必要がある
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //今回表示を行う。cellオブジェクト（１行）を取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
        //cellにお菓子のタイトル設定
        cell.textLabel?.text = okashiList?[indexPath.row].name
        //お菓子の画像を取得
        if let imageData = try? Data(contentsOf: okashiList![indexPath.row].image){
            cell.imageView?.image = UIImage(data:imageData)
        }
        //設定済みのcellオブジェクトを画面に反映
        return cell
    }
}
