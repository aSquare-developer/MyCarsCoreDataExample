//
//  ViewController.swift
//  MyCars
//
//  Created by Ivan Akulov on 07/11/16.
//  Copyright © 2016 Ivan Akulov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var context: NSManagedObjectContext!
    
    //  lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var lastTimeStartedLabel: UILabel!
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var myChoiceImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDataFromFile() {
        
        /* Создаём запрос. */
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mark != nil")
        
        var records = 0 /* Создаём переменную, которая хранит в себе кол-во записей в context */
        
        /* Пытаемся извлеч записи по нашему запросу */
        do {
            let count = try context.count(for: fetchRequest)
            records = count
            print("Data is there already")
        } catch {
            print(error.localizedDescription)
        }
        
        /*
         Проверяем количество записей в CoreData
         Если у нас кол-во записей равно 0, тогда мы продолжаем исполнение кода.
         Если же не равно 0 т.е. в нашем запросе имеются записи, в дальнейшем будем извлекать.
         */
        guard records == 0 else { return }
        
        /* Находим путь до нашего файла, в котором храниться вся информация о автомобилях */
        let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist")
        
        /* Мы знаем что наши данные хранятся в виде массива, для этого мы создаём массив, из контента этого файла. */
        let dataArray = NSArray(contentsOfFile: pathToFile!)!
        
        /* С помощью цикла извлекаем из нашего запроса данные и сохранаем их в массив */
        for dictionary in dataArray {
            let entity = NSEntityDescription.entity(forEntityName: "Car", in: context) /* Обращаемся с нашей сущности */
            let car = NSManagedObject(entity: entity!, insertInto: context) as! Car /* Создаём объект на базе нашей сущности */
            
            let carDictionary = dictionary as! NSDictionary
            car.mark = carDictionary["mark"] as? String
            car.model = carDictionary["model"] as? String
            car.rating = carDictionary["rating"] as! Double
            car.lastStarted = carDictionary["lastStarted"] as? Date
            car.timesDriven = carDictionary["timesDriven"] as! Int16
            car.myChoice = carDictionary["myChoice"] as! Bool
            car.imagesData = carDictionary["imageData"] as? Data
//            let imageName = carDictionary["imageName"] as? String
//            let image = UIImage(named: imageName!)
//            let imageData = image!.pngData()
//            car.imagesData = imageData as NSData?
            
            /*
                Обрабатываем цвет, он храниться как словарь,
                в котором есть 3 ключа которому соответствует 3 значения,
                для извлечения этих значений мы создаём метод getColor
            */
            let colorDictionary = carDictionary["tintColor"] as? NSDictionary
            car.tintColor = getColor(colorDictionary: colorDictionary!)
            
        }
    }
    
    /* Извлекаем из словоря colorDictionary цвета, и возвращаем их как UIColor. */
    func getColor(colorDictionary: NSDictionary) -> UIColor {
        let red = colorDictionary["red"] as! NSNumber
        let green = colorDictionary["green"] as! NSNumber
        let blue = colorDictionary["blue"] as! NSNumber
        
        return UIColor(red: CGFloat(red.floatValue) / 255,
                       green: CGFloat(green.floatValue) / 255,
                       blue: CGFloat(blue.floatValue) / 255,
                       alpha: 1.0)
    }
    
    @IBAction func segmentedCtrlPressed(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func startEnginePressed(_ sender: UIButton) {
        
    }
    
    @IBAction func rateItPressed(_ sender: UIButton) {
        
    }
}

