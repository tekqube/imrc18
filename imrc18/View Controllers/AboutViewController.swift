import UIKit

class AboutViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @IBAction func openFacebookPage(sender : AnyObject?) {
        if let url = URL(string: "https://www.facebook.com/imrcsanfrancisco") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func openWebsite(sender : AnyObject?) {
        if let url = URL(string: "https://imrc.mmna.org") {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
