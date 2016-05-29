import UIKit

class FormTextFieldTableViewCell: UITableViewCell {
  @IBOutlet var label: UILabel!
  @IBOutlet var textField: UITextField!
  typealias ValueCallback = (String?) -> Void
  var valueCallback: ValueCallback?

  var keyboardType: UIKeyboardType = .Default {
    didSet {
      textField.keyboardType = keyboardType
    }
  }

  override func awakeFromNib() {
    textField.delegate = self
    textField.addTarget(self, action: #selector(textChanged), forControlEvents: .EditingDidEnd)
  }

  func configure(labelText: String, value: String?, onChange: ValueCallback? = .None) {
    label.text = labelText
    textField.text = value
    valueCallback = onChange
  }

  @objc private func textChanged() {
    valueCallback?(textField.text)
  }
}

extension FormTextFieldTableViewCell: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textChanged()
    return false
  }
}
