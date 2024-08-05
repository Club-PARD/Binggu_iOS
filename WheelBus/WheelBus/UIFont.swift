//
//  UIFont.swift
//  WheelBus
//
//  Created by 유재혁 on 8/2/24.
//
import UIKit

extension UIFont {
    enum NanumSquareNeoWeight: String {
        case regular = "Regular"
        case light = "Light"
        case bold = "Bold"
        case extraBold = "ExtraBold"
        case heavy = "Heavy"
        
        fileprivate var realFontName: String {
            switch self {
            case .regular: return "NanumSquareNeo-bRg"
            case .light: return "NanumSquareNeo-aLt"
            case .bold: return "NanumSquareNeo-cBd"
            case .extraBold: return "NanumSquareNeo-dEb"
            case .heavy: return "NanumSquareNeo-eHv"
            }
        }
    }
    
    static func nanumSquareNeo(_ weight: NanumSquareNeoWeight, size: CGFloat) -> UIFont {
        return UIFont(name: weight.realFontName, size: size) ?? .systemFont(ofSize: size)
    }
}
