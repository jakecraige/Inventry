import UIKit
import MTBBarcodeScanner

class BarcodeScannerViewController: UIViewController {
  @IBOutlet var scannerContainerView: UIView!
  @IBOutlet var scanBarView: UIView!
  var scanner: MTBBarcodeScanner!
  var scannedBarcode: String?
  var receiveBarcodeCallback: ((String) -> Void)?

  override func viewDidLoad() {
    scanner = MTBBarcodeScanner(previewView: scannerContainerView)

    MTBBarcodeScanner.requestCameraPermission { [unowned self] success in
      if success {
        self.startScanning()
      } else {
        // Fail gracefully
        print("Camera permission denied")
      }
    }
  }

  @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }

  fileprivate func startScanning() {
    scanner.startScanning { [weak self] avCodes in
      guard let `self` = self,
            let avCodes = avCodes else { return }
      let codes = avCodes
        .flatMap { $0 as? AVMetadataMachineReadableCodeObject }
        .filter { $0.stringValue != nil }
        .map { $0.stringValue as String }
      if let code = codes.first {
        self.scanner.stopScanning()
        self.receiveBarcodeCallback?(code)
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
}
