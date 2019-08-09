//
//  TaskTableViewCell.swift
//  Tasks
//

import UIKit

class TaskTableViewCell: UITableViewCell, UITextViewDelegate {
    
    
    // MARK: Properties
    
    @IBOutlet weak var textView: UITextView!
    
    weak var delegate: TaskTableViewCellDelegate?
    
    var textHeight: CGFloat?
    
    
    // MARK: Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textView.delegate = self
        
        // Double tap gesture
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapToEdit))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        self.contentView.addGestureRecognizer(doubleTapGesture)
        
        // Tap and hold gesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(tapAndHold))
        longPressGesture.numberOfTouchesRequired = 1
        longPressGesture.delegate = self
        self.contentView.addGestureRecognizer(longPressGesture)
    }
    
    // MARK: Actions
    
    @objc func doubleTapToEdit(tapGesture: UITapGestureRecognizer) {
        textView.isUserInteractionEnabled = true
        textView.becomeFirstResponder()
    }
    
    @objc func tapAndHold(longPressGesture: UILongPressGestureRecognizer) {
        delegate?.longPressForCell(cell: self, gesture: longPressGesture)
    }
    
    // MARK: UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Save the textView height for comparison...
        textHeight = textView.frame.size.height
        
        // Dismiss the keyboard
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        // Update the data
        delegate?.textChangedForCell(cell: self, text: textView.text)

        // Check if textView changed height...
        let w = textView.frame.size.width
        let h = TaskTableViewCell.textViewDynamicHeight(forText: textView.text, constrainedToWidth: w)

        // Update the table view
        if (h != textHeight) {
            delegate?.cellHeightDidChange(cell: self)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        textView.isUserInteractionEnabled = false
        
        // Trim the whitespace
        textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Delete cell if empty
        if (textView.text == "") {
            delegate?.removeFromTableView(cell: self)
        } else {
            delegate?.textChangedForCell(cell: self, text: textView.text)
        }
    }
    
    
    // MARK: Static Methods
    
    static func textViewDynamicHeight(forText text: String, constrainedToWidth width: CGFloat) -> CGFloat {
        
        let dummyTextView = UITextView()
        
        dummyTextView.font = UIFont.systemFont(ofSize: 24)
        dummyTextView.text = text
        
        dummyTextView.frame.size.width = width
        dummyTextView.sizeToFit()
        
        return dummyTextView.frame.size.height
    }
    
    static func cellDynamicHeight(forText text: String, constrainedToWidth width: CGFloat) -> CGFloat {
        
        // LEFT and RIGHT margins
        let w = width - 26 - 22
        
        let textViewHeight = TaskTableViewCell.textViewDynamicHeight(forText: text, constrainedToWidth: w)
        
        // TOP and BOTTOM margins
        return textViewHeight + 12 + 12
    }
}

// MARK: - TaskTableViewCellDelegate Protocol

protocol TaskTableViewCellDelegate: class {
    
    func textChangedForCell(cell: TaskTableViewCell, text: String)
    
    func cellHeightDidChange(cell: TaskTableViewCell)
    
    func removeFromTableView(cell: TaskTableViewCell)

    func longPressForCell(cell: TaskTableViewCell, gesture: UILongPressGestureRecognizer)
}
