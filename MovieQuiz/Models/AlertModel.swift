import Foundation

struct AlertModel {
    var alertTitle: String
    var alertMessage: String
    var alertButtonText: String
    
    var completion: () -> Void
}
