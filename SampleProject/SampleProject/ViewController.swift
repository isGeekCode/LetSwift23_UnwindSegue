//
//  ViewController.swift
//  test
//
//  Created by bang_hyeonseok on 2023/09/20.
//

import UIKit

class SegueID {
    static let directToB = "directToB"
    static let directToC = "directToC"
    static let inDirectToB = "InDirectToB"
    static let inDirectToC = "InDirectToC"
    static let unWindDirectToA = "unWindDirectToA"
    static let unWindInDirectToA = "unWindInDirectToA"
    static let unWindInDirectToB = "unWindInDirectToB"
}

class ViewControllerA: BaseViewController {
    
    @IBOutlet weak var vcALabel: UILabel!
    var labelValue = "viewControllerA"
    var isInDirectSegue = false

    @IBAction func unwindToA(segue: UIStoryboardSegue) { }
    
    @IBAction func inDirectToBAction(_ sender: Any) {
        isInDirectSegue = true
        performSegue(withIdentifier: SegueID.inDirectToB, sender: sender)
        setLogPerformSegue(identifier: SegueID.inDirectToB)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setLabelText(_:)), name: NSNotification.Name(SegueID.unWindInDirectToA), object: nil)
    }
    
    @objc func setLabelText(_ notification: Notification) {
        print("noti")
        if let text = notification.userInfo?["labelValue"] as? String {
            vcALabel.text = text
        }
    }
}

class ViewControllerB: BaseViewController {

    @IBOutlet weak var vcBLabel: UILabel!
    var labelValue = "viewControllerB"

    
    @IBAction func unwindToB(segue: UIStoryboardSegue) { }
    
   
    @IBAction func inDirectToCAction(_ sender: Any) {
        performSegue(withIdentifier: SegueID.inDirectToC, sender: sender)
        setLogPerformSegue(identifier: SegueID.inDirectToC)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vcBLabel.text = labelValue
    }

}

class ViewControllerC: BaseViewController {
    @IBOutlet weak var vcCLabel: UILabel!
    var labelValue = "viewControllerC"

    
    @IBAction func unwindToAAction(_ sender: Any) {
        performSegue(withIdentifier: SegueID.unWindInDirectToA, sender: sender)
        setLogPerformSegue(identifier: SegueID.unWindInDirectToA)
    }

    @IBAction func unwindToBAction(_ sender: Any) {
        performSegue(withIdentifier: SegueID.unWindInDirectToB, sender: sender)
        setLogPerformSegue(identifier: SegueID.unWindInDirectToB)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vcCLabel.text = labelValue
    }
    
}




class BaseViewController: UIViewController {
    
    // Manual Segue 실행시
    override func shouldPerformSegue(withIdentifier identifier: String,
                                     sender: Any?) -> Bool {
        let wrappedID = wrapping(identifier)
        var isOK = true
        
        switch identifier {
        case SegueID.directToB:
            isOK = true
        default: 
            isOK = true
        }

        print("""
        ========== Direct Segue Trigger activate :: \(wrappedID) ==========
        \(getClassName()) === shouldPerformSegue - identifier: \(wrappedID) ::: \(isOK)
        """)
        
        return isOK
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let wrappedID = wrapping(segue.identifier!)

        print("\(getClassName()) === prepare(for:sender:) - identifier: \(wrappedID)")
        
        switch segue.identifier {
        // wind
        case SegueID.inDirectToB, SegueID.directToB:
            
            guard let vcFromA = segue.source as? ViewControllerA else { return }
            let segueStyleStr = vcFromA.isInDirectSegue ? "inDirect" : "direct"
            guard let vcToB = segue.destination as? ViewControllerB else { return }
            vcToB.labelValue = "ViewControllerB - from vcA ::: \(segueStyleStr)"
            vcFromA.isInDirectSegue = false
            
        case SegueID.inDirectToC:
            
            guard let vcToC = segue.destination as? ViewControllerC else { return }
            vcToC.labelValue = "ViewControllerC - from vcB ::: inDirect"
            
        // unwind
        case SegueID.unWindDirectToA, SegueID.unWindInDirectToA:
            var segueStyleStr = ""
            var sourceStr = ""
            
            if let _ = segue.source as? ViewControllerC {
                segueStyleStr = "InDirect"
                sourceStr = "vcC"
                
            } else if let _ = segue.source as? ViewControllerB {
                segueStyleStr = "Direct"
                sourceStr = "vcB"
            }
            
            let value = "viewControllerA - from \(sourceStr) ::: \(segueStyleStr)"
            let userInfo = [ "labelValue" : value ]
            
            NotificationCenter.default.post(name: NSNotification.Name(SegueID.unWindInDirectToA), object: nil, userInfo: userInfo)

        case SegueID.unWindInDirectToB:
            guard let vcToB = segue.destination as? ViewControllerB else { return }
            vcToB.labelValue = "viewControllerB - from vcC ::: unWind InDirectToB"

        default:
            return
        }
    }
    
    // MARK: VC's Life-Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(getClassName()) ::: viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("\(getClassName()) ::: viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("\(getClassName()) ::: viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("\(getClassName()) ::: viewWillDisappear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("\(getClassName()) ::: viewDidDisappear")
    }
}

extension BaseViewController {
    
    func getClassName() -> String {
        let className = String(describing: type(of: self))
        return className
    }
    
    func setLogPerformSegue(identifier: String) {
        let className = getClassName()
        let wrappedID = wrapping(identifier)
        print("""
        ****************************************************************
        \(className) === performSegue(withIdentifier: \(wrappedID))
        ****************************************************************
        """)
    }
    
    func wrapping(_ identifier: String) -> String {
        return "\"\(identifier)\""
    }
}
