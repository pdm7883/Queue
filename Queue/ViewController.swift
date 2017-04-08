//
//  ViewController.swift
//  Queue
//
//  Created by Mukunda Dhirendrachar on 4/5/17.
//

import UIKit
import SceneKit

class ViewController: UIViewController, QueueProtocol, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addButtonAcction: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var queue = Queue()
    var queuename = "MyQueue"
    var item = ""
    var dupItems = [String]()
    
    // test KVO
    dynamic var queueCount : NSInteger = 0  // only Obj-C property can be KVO observerd. It works only for class
    
    // MARK: View Controller Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        queue.delegate = self
        self.textField.delegate = self
        
        let notificationName = Notification.Name("QUEUE_COUNT_UPDATED")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleQueueCountUpdatedNotification(withNotification:)),
                                               name: notificationName,
                                               object: nil)
        
        // KVO for queueCount
        addObserver(self, forKeyPath: #keyPath(queueCount),
                    options: [.new, .old],
                    context: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
        removeObserver(self, forKeyPath: #keyPath(queueCount), context: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Methods
    func insertItem(item: String) {
        queue.enqueue(item: item)
    }
    
    func displayQueue() {
        queue.display()
    }
    
    func removeItem() {
        _ = queue.dequeue()
    }
    
    // MARK: Action methods
    @IBAction func addAction(_ sender: Any) {
        if self.item.characters.count > 0 {
            insertItem(item: self.item)
            displayQueue()
            self.tableView.reloadData()
        }
        self.textField.text = nil
        self.item = ""
    }
    
    @IBAction func removeAction(_ sender: Any) {
        if let item = queue.dequeue() {
            print("Item removed : \(item)")
        }
    }
    
    // MARK: UITableView data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.queueCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        if cell != nil {
            var val = self.dupItems[indexPath.row]
            if indexPath.row == 0 {
                val += "          <-----"
            }
            cell?.textLabel?.text = val
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return queueCount == 0 ? "Queue is empty": ""
    }
    
    // MARK: UITextField delegates
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        self.item = textFieldText.replacingCharacters(in: range, with: string)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    // MARK: Message passing design patterns
    // Notification
    @objc func handleQueueCountUpdatedNotification (withNotification notification: Notification) {
        print("[NOTIFICATION] : Queue Items : \(notification.userInfo!["items"])")
    }
    
    // Delegation/Protocol
    func handleUpdatedItems(items: [String]) {
        queueCount = queue.count
        self.dupItems = items
        self.tableView.reloadData()
        print("[DELEGATION] : Queue Count : \(queueCount)")
    }
    
    // KVO for queueCount
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("[KVO] : \(keyPath): \(change?[.newKey])")
    }
}

