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
    var selectedCar: Car!
    
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
        
        /* Проверка данных в базе при загрзуке приложения */
        getDataFromFile()
        
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        let mark = segmentedControl.titleForSegment(at: 0)
        //print("mark: \(mark)")
        fetchRequest.predicate = NSPredicate(format: "mark == %@", mark!)
        
        do {
            let results = try context.fetch(fetchRequest)
            // print("result: \(results)")
            selectedCar = results[0]
            insertDataFrom(selectedCar: selectedCar)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertDataFrom(selectedCar: Car) {
        
        carImageView.image = UIImage(data: selectedCar.imagesData!)
        markLabel.text = selectedCar.mark
        modelLabel.text = selectedCar.model
        myChoiceImageView.isHidden = !(selectedCar.myChoice.self)
        ratingLabel.text = "Rating: \(selectedCar.rating)"
        numberOfTripsLabel.text = "Number of trips: \(selectedCar.timesDriven)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        lastTimeStartedLabel.text = "Last time started: \(dateFormatter.string(from: selectedCar.lastStarted! as Date))"
        //segmentedControl.tintColor = selectedCar.tintColor as? UIColor
        segmentedControl.backgroundColor = selectedCar.tintColor as? UIColor
        segmentedControl.selectedSegmentTintColor = selectedCar.tintColor as? UIColor
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
            
            let imageName = carDictionary["imageName"] as? String
            let image = UIImage(named: imageName!)
            let imageData = image!.pngData()
            car.imagesData = imageData as Data?
            
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
        let timesDriven = Int(selectedCar.timesDriven)
        selectedCar.timesDriven = Int16(timesDriven + 1)
        selectedCar.lastStarted = Date()
        
        do {
            try context.save()
            insertDataFrom(selectedCar: selectedCar)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func rateItPressed(_ sender: UIButton) {
        
        /* Создаём Alert Controller */
        let ac = UIAlertController(title: "Rate it", message: "Rate this car please", preferredStyle: .alert)
        
        /* Создаёт кнопку ОК для нашего Alert Controller'a */
        let ok = UIAlertAction(title: "OK", style: .default) { action in
            let textField = ac.textFields?[0]
            self.update(rating: textField!.text!)
        }
        
        /* Создаёт кнопку Cancel для нашего Alert Controller'a */
        let cancel = UIAlertAction(title: "Cancel", style: .default)
        
        /* Добавляем в наш Alert Controller текстовое поле и изменяем его тип, чтобы можно было вводить только цифры */
        ac.addTextField { textField in
            textField.keyboardType = .numberPad
        }
        
        ac.addAction(ok) /* Добавляем в наш Alert Controller кнопку ОК */
        ac.addAction(cancel) /* Добавляем в наш Alert Controller кнопку Cancel */
        present(ac, animated: true) /* Презентуем наш Alert Controller при нажатии на кнопку Rate it */
        
    }
    
    func update(rating: String) {
        selectedCar.rating = Double(rating)!
        
        do {
            try context.save()
            insertDataFrom(selectedCar: selectedCar)
        } catch {
            
            let ac = UIAlertController(title: "Wrong value", message: "Value must be 1 to 10", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            ac.addAction(ok)
            present(ac, animated: true, completion: nil)
            
            print(error.localizedDescription)
        }
    }
}

