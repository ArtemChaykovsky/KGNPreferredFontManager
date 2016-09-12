//
//  PreferredFontTextField.swift
//  KGNPreferredFontManager
//
//  Created by David Keegan on 10/29/15.
//  Copyright © 2015 David Keegan. All rights reserved.
//

import UIKit

private extension Selector {
    static let contentSizeCategoryDidChange = #selector(PreferredFontTextField.contentSizeCategoryDidChange(notification:))
    static let preferredFontManagerDidChange = #selector(PreferredFontTextField.preferredFontManagerDidChange(notification:))
}

/// Subclass of `UITextField` whos font is controlled by
/// the `textStyle` and `preferredFontManager` properties.
/// The font used is automaticly updated when the user changes
/// their accesability text size setting.
open class PreferredFontTextField: UITextField {

    // TODO: before iOS 10 this may not behave as expected
    private var lastSizeCategory: UIContentSizeCategory = .medium
    private var sizeCategory: UIContentSizeCategory {
        if #available(iOSApplicationExtension 10.0, *) {
            // TODO: is this always unspecified
            if self.traitCollection.preferredContentSizeCategory != .unspecified {
                return self.traitCollection.preferredContentSizeCategory
            }
        }
        return self.lastSizeCategory
    }
    
    /// The text style to be used.
    /// Defaults to `UIFontTextStyleBody`.
    open var textStyle: UIFontTextStyle = .body {
        didSet {
            self.updateFont()
        }
    }

    /// The preferred font manager object to use.
    /// Defaults to `PreferredFontManager.sharedManager()`.
    open var preferredFontManager: PreferredFontManager? = PreferredFontManager.shared {
        didSet {
            self.updateFont()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    /// Initialize a `PreferredFontLabel` object with a given textStyle.
    public convenience init(textStyle: UIFontTextStyle) {
        self.init(frame: CGRect.zero)
        self.textStyle = textStyle
        self.updateFont()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// This `setup` method is called when initalized.
    /// Override this method to customize the setup of the button object.
    open func setup() {
        self.updateFont()
        NotificationCenter.default.addObserver(
            self, selector: .contentSizeCategoryDidChange,
            name: .UIContentSizeCategoryDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: .preferredFontManagerDidChange,
            name: NSNotification.Name(rawValue: PreferredFontManagerDidChangeNotification), object: nil)
    }

    private func updateFont() {
        if let font = self.preferredFontManager?.preferredFont(forTextStyle: self.textStyle, sizeCategory: self.sizeCategory) {
            self.font = font
        } else  {
            self.font = UIFont.preferredFont(forTextStyle: self.textStyle)
        }
    }

    @objc fileprivate func preferredFontManagerDidChange(notification: Notification) {
        guard let object = notification.object as? [String: Any] else {
            return
        }
        
        let preferredFontManager = object[PreferredFontManagerObjectKey] as? PreferredFontManager
        let textStyle = object[PreferredFontManagerTextStyleKey] as? UIFontTextStyle
        if preferredFontManager == self.preferredFontManager && textStyle == self.textStyle {
            self.updateFont()
        }
    }

    @objc fileprivate func contentSizeCategoryDidChange(notification: Notification) {
        if let object = notification.object as? [String: Any] {
            if let sizeCategory = object[UIContentSizeCategoryNewValueKey] as? UIContentSizeCategory {
                self.lastSizeCategory = sizeCategory
            }
        }
        self.updateFont()
    }

}
