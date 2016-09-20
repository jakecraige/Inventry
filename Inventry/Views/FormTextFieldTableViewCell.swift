import UIKit

class FormTextFieldTableViewCell: UITableViewCell {
  @IBOutlet var label: UILabel!
  @IBOutlet var textField: UITextField!
  typealias ValueCallback = (String?) -> Void
  var valueCallback: ValueCallback?

  var keyboardType: UIKeyboardType = .default {
    didSet {
      textField.keyboardType = keyboardType
    }
  }

  override func awakeFromNib() {
    textField.delegate = self
  }

  func configure(_ labelText: String, value: String?, changeEvent: UIControlEvents = .editingChanged, onChange: ValueCallback? = .none) {
    label.text = labelText
    textField.text = value
    valueCallback = onChange
    textField.addTarget(self, action: #selector(textChanged), for: changeEvent)
  }

  @objc fileprivate func textChanged() {
    valueCallback?(textField.text)
  }
}

extension FormTextFieldTableViewCell: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textChanged()
    return false
  }
}
