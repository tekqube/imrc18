import UIKit

class SpeakerInfoViewController : UIViewController {
    @IBOutlet weak var textView : UITextView?;
    var bios: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView?.text = (bios?.count)! < 1 ? "Description not available for this speaker" : bios ;
        textView?.isEditable = false;
        textView?.dataDetectorTypes = UIDataDetectorTypes.all;
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
}
