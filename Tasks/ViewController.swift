//
//  ViewController.swift
//  Tasks
//

import UIKit
import os.log

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TaskTableViewCellDelegate, KeyboardHandler {
    
    
    // MARK: Properties
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var pullIconView: PullIconView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButtonContainer: UIView!
    
    @IBOutlet weak var backgroundViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dayLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollIndicatorTopConstraint: NSLayoutConstraint!
    
    var addButtonVisible: Bool = true
    
    var BACKGROUND_TOP: CGFloat?
    var LABEL_TOP: CGFloat?
    var ICON_TOP:CGFloat?
    
    var tasks = [Task]()
    
    var draggingIndexPath: IndexPath?
    var draggableView: UIView?
    var touchStartingPoint: CGPoint?
    var draggableViewStartingPoint: CGPoint?
    
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load any saved tasks, otherwise load sample data
        if let savedTasks = loadTasks() {
            tasks += savedTasks
        } else {
            loadSampleTasks()
        }
    
        // Subscribe to notifications
        NotificationCenter.default.addObserver(self, selector: #selector(saveTasks), name: .save, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshOnWake), name: .wake, object: nil)
        startObservingKeyboardChanges()
        
        // Save the constraint values
        BACKGROUND_TOP = backgroundViewTopConstraint.constant
        LABEL_TOP = dayLabelTopConstraint.constant
        ICON_TOP = scrollIndicatorTopConstraint.constant
        
        // Layer adjustments
        backgroundView.layer.cornerRadius = 32
        addButtonBlurView()
        
        // Update interface elements
        updateDayOfWeekLabel()
        updateEmptyStateLabel()
        updateIconBadge()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Show welcome screen first time user runs the app
        if (FirstLaunch().isFirstLaunch) {
            showWelcomeScreen()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addButtonBlurView() {
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = addButtonContainer.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.cornerRadius = (blurEffectView.frame.size.width / 2)
        blurEffectView.clipsToBounds = true
        
        addButtonContainer.insertSubview(blurEffectView, at: 0)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let text = tasks[indexPath.row].text
        let width = tableView.frame.size.width
        return TaskTableViewCell.cellDynamicHeight(forText: text, constrainedToWidth: width)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "TaskTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TaskTableViewCell  else {
            fatalError("The dequeued cell is not an instance of \(cellIdentifier).")
        }
        
        let task = tasks[indexPath.row]
        
        cell.textView.text = task.text
        cell.delegate = self
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Editing the table view
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // Create a new row with empty task
        if (editingStyle == .insert) {
            let newTask:Task = Task(text: "")!
            tasks.insert(newTask, at: 0)
            tableView.insertRows(at: [indexPath], with: .fade)
        }
        
        // Delete the row from the data source
        else if (editingStyle == .delete) {
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        updateEmptyStateLabel()
        updateIconBadge()
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tasks.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }
    
    // Custom delete button
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteButton = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.tableView(self.tableView, commit: .delete, forRowAt: indexPath)
            return
        })
        
        deleteButton.backgroundColor = #colorLiteral(red: 0.9687580466, green: 0, blue: 0, alpha: 1)
        
        return [deleteButton]
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        // Reset elements
        dayLabelTopConstraint.constant = LABEL_TOP!
        scrollIndicatorTopConstraint.constant = ICON_TOP!
        pullIconView.togglePlusIcon(visible: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // If pulling down...
        let offset = -scrollView.contentOffset.y
        if (offset >= 0.0) {

            backgroundViewTopConstraint.constant = offset + BACKGROUND_TOP!
            scrollIndicatorTopConstraint.constant = offset + ICON_TOP!
            
            // Scroll indicator icon
            var distance:CGFloat = 10.0
            //pullIconView.toggleAnimation(animate: (offset >= distance))
            
            // Add button
            distance = 40.0
            toggleAddButton(hidden: (offset < distance))
            
            // Fade opacity
            distance = 80.0
            let alpha: CGFloat = offset/distance
            dayLabel.alpha = alpha
            pullIconView.alpha = alpha
            
            // Day of week label
            if (offset >= distance) {
                dayLabelTopConstraint.constant = offset - distance + LABEL_TOP!
            }
            
            // Scroll progress indicator
            distance = 100.0
            let percent = min(offset/distance, 1.0)
            pullIconView.setProgress(percent: percent)
            
            // Hide/show plus icon
            pullIconView.togglePlusIcon(visible: (offset >= distance))
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        // Pull down and release to add new
        if (scrollView.contentOffset.y <= -100) {
            addButtonPressed(UIButton())
        }
    }
    
    
    // MARK: TaskTableViewCellDelegate
    
    func longPressForCell(cell: TaskTableViewCell, gesture: UILongPressGestureRecognizer) {
        
        /* TOUCH START */
        if (gesture.state == .began) {
            
            // Freeze the interface while dragging
            self.view.isUserInteractionEnabled = false
            addButtonContainer.fadeOut()
            
            draggingIndexPath = tableView.indexPath(for: cell)!
            
            // Add the draggable view as a snapshot of the cell
            let cellFrame = view.convert(cell.bounds, from: cell)
            draggableView = cell.snapshotView(afterScreenUpdates: false)
            draggableView!.frame = cellFrame
            draggableView!.backgroundColor = #colorLiteral(red: 0.09867740422, green: 0.09736778587, blue: 0.1405477226, alpha: 1)
            draggableView!.dropShadow()
            self.view.addSubview(draggableView!)
            
            cell.isHidden = true
            
            // Save the points for reference
            touchStartingPoint = gesture.location(in: self.view)
            draggableViewStartingPoint = draggableView!.center
        }
        
        /* TOUCH MOVE */
        else if (gesture.state == .changed) {
            
            // Move the view and handle changes
            let point = gesture.location(in: self.view)
            moveViewRelativeToPoint(newPoint: point)
        }
        
        /* TOUCH END */
        else if (gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed) {
            
            // Animate cell back into place
            let cellFrame = view.convert(cell.bounds, from: cell)
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                self.draggableView!.frame = cellFrame
            }) { (finished) in
                cell.isHidden = false
                self.draggableView!.removeFromSuperview()
                self.draggableView = nil
                
                // Reset the interface
                self.view.isUserInteractionEnabled = true
                self.addButtonContainer.fadeIn()
            }
        }
    }
    
    func moveViewRelativeToPoint(newPoint: CGPoint) {
        
        // Move the draggable view
        var center: CGPoint = draggableViewStartingPoint!
        center.y += (newPoint.y - touchStartingPoint!.y)
        draggableView!.center = center
        
        // Check if overlapping cells should change places
        let newIndexPath: IndexPath? = checkForOverlappingCells()
        if (newIndexPath != nil) {
            
            // SWAP PLACES
            tableView(tableView, moveRowAt: draggingIndexPath!, to: newIndexPath!)
            
            draggingIndexPath = newIndexPath
        }
    }
    
    func checkForOverlappingCells() -> IndexPath? {
        
        var newIndexPath: IndexPath?
        
        let center: CGPoint = tableView.convert(draggableView!.center, from: self.view)
        
        for cell in tableView.visibleCells {
            if (cell.frame.contains(center)) {
                let cellIndexPath: IndexPath = tableView.indexPath(for: cell)!
                let isTheFromCell = (cellIndexPath == draggingIndexPath)
                if (!isTheFromCell) {
                    let dragFrame: CGRect = tableView.convert(draggableView!.frame, from: self.view)
                    
                    let dragHeight: CGFloat = dragFrame.size.height // - (SHADOW * 2))
                    
                    if (cell.frame.size.height > dragHeight) {
                        
                        /*
                         Evaluate using a smaller inner rect the size of the dragging
                         cell so the cells don't switch more than once (necessary because
                         of the variable height of the cells)...
                         */
                        let innerRect: CGRect = CGRect(x: cell.frame.origin.x,
                                                       y: cell.center.y - (dragHeight / 2),
                                                       width: cell.frame.size.width,
                                                       height: dragHeight)
                        
                        if (innerRect.contains(center)) {
                            newIndexPath = cellIndexPath;
                            break;
                        }
                    } else {
                        newIndexPath = cellIndexPath;
                        break;
                    }
                }
            }
        }
        
        return newIndexPath
    }
    
    func textChangedForCell(cell: TaskTableViewCell, text: String) {
        
        // Update the task with the new text
        let indexPath: IndexPath = tableView.indexPath(for: cell)!
        let task = tasks[indexPath.row]
        task.text = text
    }
    
    func cellHeightDidChange(cell: TaskTableViewCell) {
        
        // Update the tableView layout
        DispatchQueue.main.async {
            self.tableView?.beginUpdates()
            self.tableView?.endUpdates()
        }
    }
    
    func removeFromTableView(cell: TaskTableViewCell) {
        
        // Remove row from tableView
        let indexPath: IndexPath = tableView.indexPath(for: cell)!
        tableView(tableView, commit: .delete, forRowAt: indexPath)
    }
    
    
    // MARK: KeyboardHandler
    
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    // MARK: Actions
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        // Add new task to the top of the list
        let indexPath: IndexPath = [0, 0]
        tableView(tableView, commit: .insert, forRowAt: indexPath)
        
        // Scroll to the top to make it visible
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)

        // Show the keyboard for the new cell
        let taskCell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell
        taskCell?.textView.becomeFirstResponder()
    }
    
    
    // MARK: Private Methods
    
    private func loadSampleTasks() {
        tasks += Task.sampleTasks()
    }
    
    private func loadTasks() -> [Task]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Task.ArchiveURL.path) as? [Task]
    }

    @objc private func saveTasks() {

        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(tasks, toFile: Task.ArchiveURL.path)

        if isSuccessfulSave {
            os_log("Tasks successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save tasks...", log: OSLog.default, type: .error)
        }
    }
    
    @objc private func refreshOnWake() {
        updateDayOfWeekLabel()
    }
    
    private func toggleAddButton(hidden: Bool) {
        if hidden {
            if !addButtonVisible {
                addButtonContainer.fadeIn()
                addButtonVisible = true
            }
        } else {
            if addButtonVisible {
                addButtonContainer.fadeOut()
                addButtonVisible = false
            }
        }
    }
    
    private func updateDayOfWeekLabel() {
        let day = Calendar.current.component(.weekday, from: Date()) - 1
        let week = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        dayLabel.text = week[day]
    }
    
    private func updateEmptyStateLabel() {
        emptyStateLabel.isHidden = (tasks.count > 0)
    }
    
    private func updateIconBadge() {
        UIApplication.shared.applicationIconBadgeNumber = self.tasks.count
    }
    
    private func showWelcomeScreen() {
        let vc = WelcomeViewController.loadFromNib()
        present(vc, animated: false, completion: nil)
    }
    
}
