import UIKit

class FoodViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!;
    @IBOutlet weak var bottomFilter : UIView?;
    @IBOutlet weak var activityView : UIActivityIndicatorView?;
    
    var sections : NSMutableArray = NSMutableArray();
    var foodList : NSMutableArray = [];
    var firstWorksheet: BRAWorksheet = BRAWorksheet();
    var spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage();
    var firstTimeLoad : Bool = true;
    var selectedButton : Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView?.isHidden = false;
        
        NSLog(" After Data is read from Food File..");
        let subview = view.viewWithTag(1)
        if subview is UIButton {
            let button = subview as! UIButton;
            // Selected State
            button.backgroundColor = UIColor(hexString: "a00000")
            button.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            NSLog(" Before Reading Food File..");
            self.spreadsheet =  projectUtil.getOfficeDocumentPackage(fileName: String(format: "%@",Constants.foodMenuFileName));
            
            if (self.spreadsheet.workbook != nil && self.spreadsheet.workbook.worksheets.count > 0) {
                self.firstWorksheet = self.spreadsheet.workbook.worksheets[0] as! BRAWorksheet
                NSLog(" After Opening Food File..");
                
                
                self.getSheetData(data: 0);
            }
            self.activityView?.isHidden = true;
        };
    }
    
    @IBAction func foodByDay(sender : UIButton?) {
        firstTimeLoad = false;
        
        firstWorksheet = spreadsheet.workbook.worksheets[(sender?.tag)! - 1] as! BRAWorksheet
        
        for subview in (self.bottomFilter?.subviews)! {
            if let button = subview as? UIButton {
                // this is a button
                if (button.tag >= 1 && button.tag <= 5){
                    button.backgroundColor = UIColor.white
                    button.setTitleColor(UIColor(hexString: "a00000"), for: .normal)
                } else {
                    NSLog("Tag  is not configured right")
                }
            }
        }
        
        if ((sender?.tag)! < 4) {
            tableView.setContentOffset(.zero, animated: true);
        }
        
        sender?.backgroundColor = UIColor(hexString: "a00000")
        sender?.setTitleColor(UIColor.white, for: .normal)
        sender?.titleLabel?.textColor = UIColor.white;
        
        if (selectedButton != sender?.tag) {
            sections = NSMutableArray();
            foodList = NSMutableArray();
            selectedButton = (sender?.tag)!;
            getSheetData(data: (sender?.tag)!);
        } else {
            NSLog(" Selected Button clicked is same as the other button... ");
        }
    }
    
    func getSheetData(data: Int) {
        var isLoopAllowed = true;
        var i = 3;
        var emptyRow = 0;
        
        var foodArray : NSMutableArray = [];
        while (isLoopAllowed) {
            NSLog(" Loop : %d", i);
            let time = firstWorksheet.cell(forCellReference: "B\(i)")?.stringValue();
            let type = firstWorksheet.cell(forCellReference: "C\(i)")?.stringValue();
            let cuisine = firstWorksheet.cell(forCellReference: "D\(i)")?.stringValue();
            let item = firstWorksheet.cell(forCellReference: "E\(i)")?.stringValue();
            
            if ((cuisine != nil && cuisine != "") || (item != nil && item != "")) {
                let food : Food = Food();
                food.mealName = (item != nil ? item : "")! as NSString;
                food.cuisine = (cuisine != nil ? cuisine : "")! as NSString;
                
                foodArray.add(food);
            } else if (time != nil && time != "" && type != nil && type != "") {
                sections.add(String(format: "%@==%@",type!, time!));
                NSLog(" Section FOUND...");
            } else {
                if foodArray.count > 0 {
                    foodList.add(foodArray);
                }
                
                foodArray = NSMutableArray();
                emptyRow = emptyRow + 1;

                if (emptyRow > 10) {
                    isLoopAllowed = false;
                    break;
                }
            }
            
            i=i+1;
        }
        self.tableView.reloadData();
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(" Number of Section: %d", self.sections.count);
        return self.sections.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(" Number of rows in Section: %d", (self.foodList.count > 0 ? (self.foodList[section] as AnyObject).count : 0));
        return (self.foodList.count > 0 ? (self.foodList[section] as AnyObject).count : 0);
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodTableViewCell", for: indexPath) as! FoodTableViewCell
        
        let food = (self.foodList.object(at: indexPath.section) as AnyObject).object(at: indexPath.row) as! Food;
        cell.name?.text = String(format: "%@",food.mealName);
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "foodSectionViewCell") as! FoodSectionHeaderCell
        
        if (self.sections.count > 0) {
            var strs  = (self.sections[section] as AnyObject).components(separatedBy: "==");
            headerCell.sectionName?.text = strs[0];
            headerCell.time?.text = strs[1];
            
            return headerCell;
        }
        
        return nil;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
}
