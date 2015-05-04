//
//  PreferredFontTextField.swift
//  Vesting
//
//  Created by David Keegan on 1/11/15.
//  Copyright (c) 2015 David Keegan. All rights reserved.
//

import UIKit

class PreferredFontTextField: UITextField {

    var textStyle: String? = UIFontTextStyleBody {
        didSet {
            self.updateFont()
        }
    }
    var preferredFontManager: PreferredFontManager? {
        didSet {
            self.updateFont()
        }
    }

    convenience init(textStyle: String) {
        self.init()
        self.textStyle = textStyle
        self.setup()
    }

    init() {
        super.init(frame: CGRectZero) // TODO: is this the best work around?
        self.setup()
    }

    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.setup()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // Use this to override the setup of the label
    func setup() {
        self.updateFont()
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: "contentSizeCategoryDidChangeNotification:",
            name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }

    private func updateFont() {
        if let preferredFontManager = self.preferredFontManager {
            if let textStyle = self.textStyle {
                if let font = preferredFontManager.preferredFontForTextStyle(textStyle) {
                    self.font = font
                }
            } else if let font = preferredFontManager.preferredFontForTextStyle(UIFontTextStyleBody) {
                self.font = font
            }
        } else if let textStyle = self.textStyle {
            self.font = UIFont.preferredFontForTextStyle(textStyle)
        } else {
            self.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        }
    }

    @objc private func contentSizeCategoryDidChangeNotification(notification: NSNotification) {
        self.updateFont()
    }

}
