//
//  ViewController.swift
//  test
//
//  Created by bang_hyeonseok on 2023/09/20.
//

import UIKit

class SegueID {
    static let actionToB = "actionToB"
    static let manualToB = "manualToB"
    static let manualToC = "manualToC"
    static let unWindActionToA = "unWindActionToA"
    static let unWindManualToA = "unWindManualToA"
    static let unWindManualToB = "unWindManualToB"
}

class ViewControllerA: BaseViewController {
    
    @IBOutlet weak var vcALabel: UILabel!
    var labelValue = "viewControllerA"
    var isManualSegue = false

    @IBAction func unwindToA(segue: UIStoryboardSegue) { }
    
    @IBAction func inDirectToBAction(_ sender: Any) {
        isManualSegue = true
        performSegue(withIdentifier: SegueID.manualToB, sender: sender)
        setLogPerformSegue(identifier: SegueID.manualToB)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setLabelText(_:)), name: NSNotification.Name(SegueID.unWindManualToA), object: nil)
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
        performSegue(withIdentifier: SegueID.manualToC, sender: sender)
        setLogPerformSegue(identifier: SegueID.manualToC)
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
        performSegue(withIdentifier: SegueID.unWindManualToA, sender: sender)
        setLogPerformSegue(identifier: SegueID.unWindManualToA)
    }

    @IBAction func unwindToBAction(_ sender: Any) {
        performSegue(withIdentifier: SegueID.unWindManualToB, sender: sender)
        setLogPerformSegue(identifier: SegueID.unWindManualToB)
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
        case SegueID.actionToB:
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
        case SegueID.manualToB, SegueID.actionToB:
            
            guard let vcFromA = segue.source as? ViewControllerA else { return }
            let segueStyleStr = vcFromA.isManualSegue ? "Manual" : "Action"
            
            guard let vcToB = segue.destination as? ViewControllerB else { return }
            vcToB.labelValue = "From A ::: \(segueStyleStr)"
            vcFromA.isManualSegue = false
            
        case SegueID.manualToC:
            
            guard let vcToC = segue.destination as? ViewControllerC else { return }
            vcToC.labelValue = "From B ::: Manual Segue"
        // unwind
        case SegueID.unWindActionToA, SegueID.unWindManualToA:
            
            var segueStyleStr = ""
            var sourceStr = ""
            
            if let _ = segue.source as? ViewControllerC {
                segueStyleStr = "Manual unWind"
                sourceStr = "C"
                
            } else if let _ = segue.source as? ViewControllerB {
                segueStyleStr = "Action unWind"
                sourceStr = "B"
            }
            
            let value = "From \(sourceStr) ::: \(segueStyleStr)"
            let userInfo = [ "labelValue" : value ]
            
            NotificationCenter.default.post(name: NSNotification.Name(SegueID.unWindManualToA), object: nil, userInfo: userInfo)

        case SegueID.unWindManualToB:
            
            guard let vcToB = segue.destination as? ViewControllerB else { return }
            vcToB.labelValue = "From C ::: Manual unWind"
            
            print("vcToB: \(vcToB.labelValue)")
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
