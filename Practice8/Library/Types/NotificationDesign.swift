//
//  NotificationDesign.swift
//  HRPoll_New
//
//  Created by Andrew on 20.12.2022.
//

import Foundation
import SwiftUI

//MARK: - NotificationDesign
public class NotificationDesignDefaults {
    public static var screenBackground: UIColor = .clear
    public static var screenCornerRadius: CGFloat = 20.0
    public static var entryBackground: UIColor = .white
    public static var messageColor: UIColor = .label
    public static var messageFont: UIFont = UIFont.systemFont(ofSize: 12)

    public class Buttons {
        public static var textColor: UIColor = .label
        public static var background: UIColor = .clear
        public static var font: UIFont = UIFont.systemFont(ofSize: 14)
        public static var radius: CGFloat = 4.0
    }
}

public enum NotificationDesignParams {
    case screen(backgroundColor: UIColor = NotificationDesignDefaults.screenBackground,
                cornerRadius: CGFloat = NotificationDesignDefaults.screenCornerRadius)
    case entryBackground(color: UIColor = NotificationDesignDefaults.entryBackground)
    case message(color: UIColor = NotificationDesignDefaults.messageColor,
                 font: UIFont = NotificationDesignDefaults.messageFont)
    case buttons(background: UIColor = NotificationDesignDefaults.Buttons.background,
                 textColor: UIColor = NotificationDesignDefaults.Buttons.textColor,
                 font: UIFont = NotificationDesignDefaults.Buttons.font,
                 radius: CGFloat = NotificationDesignDefaults.Buttons.radius)
}

public extension Array where Element == NotificationDesignParams {

    var screenBackground: UIColor {

        let result = self.first(where: {(item: NotificationDesignParams) in
            switch item {
            case .screen:
                return true
            default:
                return false
            }

        })

        switch result {
        case .screen(let color,
                               _)?:
            return color
        default:
            return NotificationDesignDefaults.screenBackground
        }

    }

    var screenCornerRadius: CGFloat {

        let result = self.first(where: {(item: NotificationDesignParams) in
            switch item {
            case .screen:
                return true
            default:
                return false
            }

        })

        switch result {
        case .screen(_,
                     let radius)?:
            return radius
        default:
            return NotificationDesignDefaults.screenCornerRadius
        }

    }


    var entryBackground: UIColor {

        let result = self.first(where: {(item: NotificationDesignParams) in
            switch item {
            case .entryBackground:
                return true
            default:
                return false
            }

        })

        switch result {
        case .entryBackground(let color)?:
            return color
        default:
            return NotificationDesignDefaults.entryBackground
        }

    }

    var message: (color: UIColor, font: UIFont) {

        let result = self.first(where: {(item: NotificationDesignParams) in
            switch item {
            case .message:
                return true
            default:
                return false
            }

        })

        switch result {
        case .message(let color, let font)?:
            return (color,
                    font)
        default:
            return (NotificationDesignDefaults.messageColor, NotificationDesignDefaults.messageFont)
        }

    }

    var buttons: (backgroundColor: UIColor,
                  textColor: UIColor,
                  font: UIFont,
                  radius: CGFloat) {

        let result = self.first(where: {(item: NotificationDesignParams) in
            switch item {
            case .buttons:
                return true
            default:
                return false
            }

        })

        switch result {
        case .buttons(let backgroundColor,
                      let textColor,
                      let font,
                      let radius)?:
            return (backgroundColor,
                    textColor,
                    font,
                    radius)
        default:
            return (NotificationDesignDefaults.Buttons.background,
                    NotificationDesignDefaults.Buttons.textColor,
                    NotificationDesignDefaults.Buttons.font,
                    NotificationDesignDefaults.Buttons.radius)
        }

    }

}
