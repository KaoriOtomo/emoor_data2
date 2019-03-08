//
//  ViewController.swift
//  emoor_data2
//
//  Created by 大友香穂里 on 2019/02/13.
//  Copyright © 2019年 大友香穂里. All rights reserved.
//

import UIKit
import CoreData
import CoreMotion
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var accelZ: Double = -1
    var frg = 0
    var i = 0
    var timer = Timer()
    var tasks: [Double] = []
    var tasks2: [String] = []
    @IBOutlet weak var stopbutton: UIButton!
    @IBOutlet weak var Accel: UILabel!
    @IBOutlet weak var Time: UILabel!
    @IBOutlet weak var Button: UIButton!
    @IBOutlet weak var alldata: UIButton!
    let manager = CMMotionManager()
    var locManager : CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        Time.text = "Time:"
        Accel.text = "Accel:"
        
        //バックグラウンド処理でしょうがないからロケーション取得
        locManager = CLLocationManager.init()
        locManager.allowsBackgroundLocationUpdates = true; // バックグランドモードで使用する場合YESにする必要がある
        locManager.desiredAccuracy = kCLLocationAccuracyBest; // 位置情報取得の精度
        locManager.distanceFilter = 1; // 位置情報取得する間隔、1m単位とする
        locManager.delegate = self as? CLLocationManagerDelegate;
        
        // 位置情報の認証チェック
        let status = CLLocationManager.authorizationStatus()
        if (status == .notDetermined) {
            print("許可、不許可を選択してない");
            
            // 常に許可するように求める
            locManager?.requestAlwaysAuthorization();
        }
        else if (status == .restricted) {
            print("機能制限している");
        }
        else if (status == .denied) {
            print("許可していない");
        }
        else if (status == .authorizedWhenInUse) {
            print("このアプリ使用中のみ許可している");
            locManager?.startUpdatingLocation();
        }
        else if (status == .authorizedAlways) {
            print("常に許可している");
            locManager?.startUpdatingLocation();
        }
        
        //**************************************************
        // CLLocationManagerDelegate
        //**************************************************
        
        // 位置情報が取得されると呼ばれる
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            // 最新の位置情報を取得 locationsに配列で入っている位置情報の最後が最新となる
            let location : CLLocation = locations.last!;
        }
        
        // 位置情報の取得に失敗すると呼ばれる
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if (status == .restricted) {
                print("機能制限している");
            }
            else if (status == .denied) {
                print("許可していない");
            }
            else if (status == .authorizedWhenInUse) {
                print("このアプリ使用中のみ許可している");
                locManager.startUpdatingLocation();
            }
            else if (status == .authorizedAlways) {
                print("常に許可している");
                locManager.startUpdatingLocation();
            }
        }
        
    }

    //ボタンタップ処理
    @IBAction func ButtonTap(_ sender: Any) {
        
        deleteData()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            let getTime = self.getData()
            self.getAccelData()
            
            self.accelZ = self.accelZ * 10000
            self.accelZ = round(self.accelZ)/10000
            
            self.kakunou(taskTime: getTime, taskAccel: self.accelZ)
            
        })
        
        
    }
    
    
    //ストップボタン
    @IBAction func stop(_ sender: Any) {
        timer.invalidate()
        
        
    }
    //遷移先値引き渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let next = segue.destination as? graphViewController
        let _ = next?.view
        
    }
    
    //時間取得
    func getData()-> (String){
        
        let format = DateFormatter()
        
        format.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        
        let taskTime = format.string(from: Date()) // 2015-12-27 19:16:31
        
        return (taskTime)
    }
    
    //加速度取得
    func getAccelData(){
        
        
        
        manager.accelerometerUpdateInterval = 1/1000; // アップデート間隔：10Hz
        //var taskAccel: Double =  0
        let accelerometerHandler: CMAccelerometerHandler = {
            [weak self] data, error in
            
            //self?.syuunou(value: data!.acceleration.z)
            //self?.Acceleration.text = "Accel(x) : \(data!.acceleration.z)" //Label に　"Acceleration : x軸" が表示される
            self?.accelZ = data!.acceleration.z
            
        }
        
        //アップデートスタート
        manager.startAccelerometerUpdates (to: OperationQueue.current!, withHandler:accelerometerHandler)
        
        usleep(10000)
        
        if manager.isAccelerometerAvailable {
            //アップデートストップ
            manager.stopAccelerometerUpdates()
        }
        
        
        
        
    }
    
    
    
    func kakunou(taskTime: String, taskAccel: Double){
        // context(データベースを扱うのに必要)を定義。
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        
        // taskにTask(データベースのエンティティです)型オブジェクトを代入します。
        // このとき、Taskがサジェストされない（エラーになる）場合があります。
        // 詳しい原因はわかりませんが、Runするか、すべてのファイルを保存してXcodeを再起動すると直るので色々試してみてください。
        let task = Task(context: context)
        
        
        // 先ほど定義したTask型データのname、categoryプロパティに入力、選択したデータを代入します。
        task.time = taskTime
        task.acceleration = taskAccel
        
        Time.text = "Time:\(taskTime)"
        Accel.text = "Accel:\(taskAccel)"
        
        // 上で作成したデータをデータベースに保存します。
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        dismiss(animated: true, completion: nil)
        

    }
    
    @IBAction func Dataprint(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            // CoreDataからデータをfetchしてtasksに格納
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            let results = try context.fetch(fetchRequest)
            tasks = []
            tasks2 = []
            
            for k in results {
                tasks.append(k.acceleration)
                
            }
            for k in results {
                tasks2.append(k.time!)
                
            }
            print(tasks)
            print(tasks2)
            
        } catch {
            print("Error")
        }
        //let access = tasks[1]as!Task
        //print(access.time!)

    }
    
    //Coredata削除
    
    func deleteData()  {
        
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        do {
            let results : Array = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
            if (results.count > 0 ) {
                let n = results.count
                // 見つかったら削除
                for k in 0...n-1 {
                let obj = results[k] as! NSManagedObject
                //let txt = obj.valueForKey(Accel) as! String
                //print("DELETE \(txt)")
                
                context.delete(obj)
                }
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
            
        } catch let error as NSError {
            // エラー処理
            print("FETCH ERROR:\(error.localizedDescription)")
        }
        
    }
    
    @IBAction func restart(_ segue: UIStoryboardSegue) {
    }
    
    
    
}


class graphViewController: UIViewController {
    
    var array_ac: [Double] = []
    var array_time: [String] = []
    @IBOutlet weak var restart: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
        drawLineGraph()
        //drawBarGraph()
        restart.setTitle("最初にもどる", for: UIControl.State.normal)
    }
    
    
    //グラフ用ファイル
    func fetch() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            // CoreDataからデータをfetchしてtasksに格納
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            let results = try context.fetch(fetchRequest)
            array_ac = []
            array_time = []
            
            for k in results {
                array_ac.append(k.acceleration+3)
                
            }
            for k in results {
                array_time.append(k.time!)
                
            }
            print(array_ac)
            print(array_time)
            
        } catch {
            print("Error")
        }
        
    }
    
    //グラフにする配列を選択、線の色も決める
    func drawLineGraph() {
        
        let array_ac_f : [CGFloat] = array_ac.map{CGFloat($0)}
        let stroke1 = LineStroke(graphPoints: array_ac_f)
        
        //let stroke2 = LineStroke(graphPoints: [3, nil, 6, 4, 4])
        
        stroke1.color = UIColor.white
        //stroke2.color = UIColor.magenta
        
        let graphFrame = LineStrokeGraphFrame(strokes: [stroke1])
        
        //グラフの大きさ、背景色
        
        //グラデーションの開始色
        let topColor = UIColor(red:0.07, green:0.13, blue:0.26, alpha:1)
        //グラデーションの開始色
        let bottomColor = UIColor(red:0.54, green:0.74, blue:0.74, alpha:1)
        
        //グラデーションの色を配列で管理
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        
        //グラデーションレイヤーを作成
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        //グラデーションレイヤーをスクリーンサイズにする
        //gradientLayer.frame = self.view.bounds
        
        //グラデーションレイヤーをビューの一番下に配置
        //self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        
        let lineGraphView = UIView(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: 200))
        lineGraphView.backgroundColor = UIColor(red: 0.086, green: 0.31, blue: 0.525, alpha: 1.0)
        //lineGraphView.backgroundColor = gradientLayer
        lineGraphView.addSubview(graphFrame)
        
        view.addSubview(lineGraphView)
    }
    
    func drawBarGraph() {
        let bars = BarStroke(graphPoints: [nil, 1, 3, 1, 4, 9, 12, 4])
        bars.color = UIColor.green
        
        let barFrame = LineStrokeGraphFrame(strokes: [bars])
        
        let barGraphView = UIView(frame: CGRect(x: 0, y: 240, width: view.frame.width, height: 200))
        barGraphView.backgroundColor = UIColor.gray
        barGraphView.addSubview(barFrame)
        
        view.addSubview(barGraphView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

protocol GraphObject {
    var view: UIView { get }
}

extension GraphObject {
    var view: UIView {
        return self as! UIView
    }
    
    func drawLine(from: CGPoint, to: CGPoint) {
        let linePath = UIBezierPath()
        
        linePath.move(to: from)
        linePath.addLine(to: to)
        
        linePath.lineWidth = 0.5
        
        let color = UIColor.white
        color.setStroke()
        linePath.stroke()
        linePath.close()
    }
}

protocol GraphFrame: GraphObject {
    var strokes: [GraphStroke] { get }
}

extension GraphFrame {
    // 保持しているstrokesの中で最大値
    var yAxisMax: CGFloat {
        return strokes.map{ $0.graphPoints }.flatMap{ $0 }.compactMap{ $0 }.max()!
    }
    
    // 保持しているstrokesの中でいちばん長い配列の長さ
    var xAxisPointsCount: Int {
        return strokes.map{ $0.graphPoints.count }.max()!
    }
    
    // X軸の点と点の幅
    var xAxisMargin: CGFloat {
        return view.frame.width/CGFloat(xAxisPointsCount)
    }
}

class LineStrokeGraphFrame: UIView, GraphFrame {
    var strokes = [GraphStroke]()
    
    convenience init(strokes: [GraphStroke]) {
        self.init()
        self.strokes = strokes
    }
    
    override func didMoveToSuperview() {
        if self.superview == nil { return }
        self.frame.size = self.superview!.frame.size
        self.view.backgroundColor = UIColor.clear
        
        strokeLines()
    }
    
    func strokeLines() {
        for stroke in strokes {
            self.addSubview(stroke as! UIView)
        }
    }
    
    override func draw(_ rect: CGRect) {
        drawTopLine()
        drawBottomLine()
        drawVerticalLines()
    }
    
    func drawTopLine() {
        self.drawLine(
            from: CGPoint(x: 0, y: frame.height),
            to: CGPoint(x: frame.width, y: frame.height)
        )
    }
    
    func drawBottomLine() {
        self.drawLine(
            from: CGPoint(x: 0, y: 0),
            to: CGPoint(x: frame.width, y: 0)
        )
    }
    
    func drawVerticalLines() {
        var n = 1
        for i in 1..<xAxisPointsCount {
            
            if n <= 10{
            
                n = n + 1}
            else{
                let x = xAxisMargin*CGFloat(i)
                self.drawLine(
                    from: CGPoint(x: x, y: 0),
                    to: CGPoint(x: x, y: frame.height)
                )
                n = 1}
        }
    }
}


protocol GraphStroke: GraphObject {
    var graphPoints: [CGFloat?] { get }
}

extension GraphStroke {
    var graphFrame: GraphFrame? {
        return ((self as! UIView).superview as? GraphFrame)
    }
    
    var graphHeight: CGFloat {
        return view.frame.height
    }
    
    var xAxisMargin: CGFloat {
        return graphFrame!.xAxisMargin
    }
    
    var yAxisMax: CGFloat {
        return graphFrame!.yAxisMax
    }
    
    // indexからX座標を取る
    func getXPoint(index: Int) -> CGFloat {
        return CGFloat(index) * xAxisMargin
    }
    
    // 値からY座標を取る(+1で調整しました)
    func getYPoint(yOrigin: CGFloat) -> CGFloat {
        let y: CGFloat = yOrigin/(yAxisMax+1) * graphHeight
        return graphHeight - y
    }
}


class LineStroke: UIView, GraphStroke {
    var graphPoints = [CGFloat?]()
    var color = UIColor.white
    
    convenience init(graphPoints: [CGFloat?]) {
        self.init()
        self.graphPoints = graphPoints
    }
    
    override func didMoveToSuperview() {
        if self.graphFrame == nil { return }
        self.frame.size = self.graphFrame!.view.frame.size
        self.view.backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        let graphPath = UIBezierPath()
        
        graphPath.move(
            to: CGPoint(x: getXPoint(index: 0), y: getYPoint(yOrigin: graphPoints[0] ?? 0))
        )
        
        for graphPoint in graphPoints.enumerated() {
            if graphPoint.element == nil { continue }
            let nextPoint = CGPoint(x: getXPoint(index: graphPoint.offset),
                                    y: getYPoint(yOrigin: graphPoint.element!))
            graphPath.addLine(to: nextPoint)
        }
        
        graphPath.lineWidth = 2.0
        color.setStroke()
        graphPath.stroke()
        graphPath.close()
    }
}

class BarStroke: UIView, GraphStroke {
    var graphPoints = [CGFloat?]()
    var color = UIColor.white
    
    convenience init(graphPoints: [CGFloat?]) {
        self.init()
        self.graphPoints = graphPoints
    }
    
    override func didMoveToSuperview() {
        if self.graphFrame == nil { return }
        self.frame.size = self.graphFrame!.view.frame.size
        self.view.backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        for graphPoint in graphPoints.enumerated() {
            let graphPath = UIBezierPath()
            
            let xPoint = getXPoint(index: graphPoint.offset)
            graphPath.move(
                to: CGPoint(x: xPoint, y: getYPoint(yOrigin: 0))
            )
            
            if graphPoint.element == nil { continue }
            let nextPoint = CGPoint(x: xPoint, y: getYPoint(yOrigin: graphPoint.element!))
            graphPath.addLine(to: nextPoint)
            
            graphPath.lineWidth = 30
            color.setStroke()
            graphPath.stroke()
            graphPath.close()
        }
    }
    
    
}
