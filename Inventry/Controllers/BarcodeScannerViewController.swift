import UIKit
import MTBBarcodeScanner

class BarcodeScannerViewController: UIViewController {
  @IBOutlet var scannerContainerView: UIView!
  @IBOutlet var scanBarView: UIView!
  var scanner: MTBBarcodeScanner!
  var scannedBarcode: String?

  override func viewDidLoad() {
    scanner = MTBBarcodeScanner(previewView: scannerContainerView)

    MTBBarcodeScanner.requestCameraPermissionWithSuccess { [unowned self] success in
      if success {
        self.startScanning()
      } else {
        // Fail gracefully
        print("Camera permission denied")
      }
    }
  }

  private func startScanning() {
    scanner.startScanningWithResultBlock { [weak self] avCodes in
      guard let `self` = self else { return }
      let codes = avCodes
        .flatMap { $0 as? AVMetadataMachineReadableCodeObject }
        .filter { $0.stringValue != nil }
        .map { $0.stringValue as String }
      self.scannedBarcode = codes.first
      if let _ = self.scannedBarcode {
        self.scanner.stopScanning()
        self.performSegueWithIdentifier("unwindChooseProductsSegue", sender: nil)
      }
    }
  }
}
