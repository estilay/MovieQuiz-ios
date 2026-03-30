import UIKit

enum Fonts {
    static let ysDisplayMediumFontName = "YSDisplay-Medium"
    static let ysDisplayMedium20 = UIFont(name: "YSDisplay-Medium", size: 20) ?? .systemFont(ofSize: 20) //to avoid crash due to Fonts
    static let ysDisplayBold23 = UIFont(name: "YSDisplay-Bold", size: 23) ?? .systemFont(ofSize: 23)
}
