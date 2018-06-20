import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift

let width = UIScreen.main.bounds.size.width
let height = UIScreen.main.bounds.size.height

class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
  let dateView = FSCalendar(frame: CGRect(x: 0, y: 30, width: width, height: height))
  let Date = UILabel(frame: CGRect(x: 5, y: 430, width: 200, height: 100))
  
  fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
  fileprivate lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.dateView.dataSource = self
    self.dateView.delegate = self
    self.dateView.today = nil
    self.dateView.tintColor = .red
    self.view.backgroundColor = .white
    dateView.backgroundColor = .white
    view.addSubview(dateView)
    
    Date.text = ""
    Date.font = UIFont.systemFont(ofSize: 60.0)
    Date.textColor = .black
    view.addSubview(Date)
    DispatchQueue(label: "background").async {
      let realm = try! Realm()
      realm.objects(Kokoro.self).forEach { kokoro in
        self.setCellColor(with: kokoro)
      }
    }
  }
  
  private func setCellColor(with kokoro: Kokoro) {
    let calendar = Calendar.current
    let date = self.getDay(kokoro.date)
    let selectDate = calendar.date(from: DateComponents(year: date.0, month: date.1, day: date.2))
    let cell = self.dateView.cell(for: selectDate!, at: .current)
    cell?.layer.cornerRadius = 10
    cell?.layer.masksToBounds = true
    switch kokoro.kokoro {
    case 1:
      cell?.backgroundColor = UIColor.joy
    case 2:
      cell?.backgroundColor = UIColor.anger
    case 3:
      cell?.backgroundColor = UIColor.sadness
    case 4:
      cell?.backgroundColor = UIColor.happiness
    default:
      cell?.backgroundColor = UIColor.rgba(red: 255, green: 255, blue: 255, alpha: 0.8)
    }
  }
  
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
    let realm = try! Realm()
    let dateStr = dateFormatter.string(from: date)
    var kokoro = realm.objects(Kokoro.self).filter("date == %d", dateStr).first
    switch kokoro {
    case .some:
      try! realm.write {
        if (kokoro?.kokoro)! >= 4 {
          kokoro?.kokoro = 0
        } else {
          kokoro?.kokoro += 1
        }
      }
    default:
      kokoro = Kokoro()
      kokoro?.date = dateStr
      try! realm.write {
        realm.add(kokoro!)
      }
    }
    self.setCellColor(with: kokoro!)
  }
  
  private func getDay(_ date:String) -> (Int,Int,Int){
    return getDay(self.dateFormatter.date(from: date)!)
  }
  
  private func getDay(_ date:Date) -> (Int,Int,Int){
    let tmpCalendar = Calendar(identifier: .gregorian)
    let year = tmpCalendar.component(.year, from: date)
    let month = tmpCalendar.component(.month, from: date)
    let day = tmpCalendar.component(.day, from: date)
    return (year,month,day)
  }
  
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
    if self.judgeHoliday(date){
      return UIColor.red
    }
    let weekday = self.getWeekIdx(date)
    switch weekday {
    case 1:
      return UIColor.red
    case 7:
      return UIColor.blue
    default:
      return nil
    }
  }
  
  private func judgeHoliday(_ date : Date) -> Bool {
    let tmpCalendar = Calendar(identifier: .gregorian)
    let year = tmpCalendar.component(.year, from: date)
    let month = tmpCalendar.component(.month, from: date)
    let day = tmpCalendar.component(.day, from: date)
    let holiday = CalculateCalendarLogic()
    return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
  }
  
  private func getWeekIdx(_ date: Date) -> Int{
    let tmpCalendar = Calendar(identifier: .gregorian)
    return tmpCalendar.component(.weekday, from: date)
  }
}
