//
//  PreferredFontButton.swift
//  Vesting
//
//  Created by David Keegan on 1/11/15.
//  Copyright (c) 2015 David Keegan. All rights reserved.
//

import UIKit

private extension Selector {
    static let contentSizeCategoryDidChange = #selector(PreferredFontButton.contentSizeCategoryDidChange(notification:))
    static let preferredFontManagerDidChange = #selector(PreferredFontButton.preferredFontManagerDidChange(notification:))
}

/// Subclass of `UIButton` whos font is controlled by
/// the `textStyle` and `preferredFontManager` properties.
/// The font used is automaticly updated when the user changes
/// their accesability text size setting.
public class PreferredFontButton: UIButton {

    /// The text style to be used.
    /// Defaults to `UIFontTextStyleBody`.
    public var textStyle: String = UIFontTextStyleBody {
        didSet {
            self.updateFont()
        }
    }

    /// The preferred font manager object to use.
    /// Defaults to `PreferredFontManager.sharedManager()`.
    public var preferredFontManager: PreferredFontManager? = PreferredFontManager.sharedManager() {
        didSet {
            self.updateFont()
        }
    }

    private var hasMovedToSuperview = false
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()

        // HACK: The buttonType convenience init
        // cannot be overwritten, so this is a hack
        // to update the font when the button is
        // first moved to a superview
        if !self.hasMovedToSuperview && self.buttonType == .system {
            self.hasMovedToSuperview = true
            self.updateFont()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }


    /// Initialize a `PreferredFontButton` object with a given textStyle.
    public convenience init(textStyle: String) {
        self.init(frame: CGRect.zero)
        self.textStyle = textStyle
        self.updateFont()
    }

    deinit {
        NotificationCenter.default().removeObserver(self)
    }

    /// This `setup` method is called when initalized.
    /// Override this method to customize the setup of the button object.
    /// Be sure to call `super.setup()` in your implementation.
    public func setup() {
        self.updateFont()
        NotificationCenter.default().addObserver(
            self, selector: .contentSizeCategoryDidChange,
            name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        NotificationCenter.default().addObserver(
            self, selector: .preferredFontManagerDidChange,
            name: PreferredFontManagerDidChangeNotification, object: nil)
    }

    private func updateFont() {
        if let font = self.preferredFontManager?.preferredFont(forTextStyle: self.textStyle) {
            self.titleLabel?.font = font
        } else  {
            self.titleLabel?.font = UIFont.preferredFont(forTextStyle: self.textStyle)
        }
    }

    @objc private func preferredFontManagerDidChange(notification: Notification) {
        let preferredFontManager = notification.object?[PreferredFontManagerObjectKey] as? PreferredFontManager
        let textStyle = notification.object?[PreferredFontManagerTextStyleKey] as? String
        if preferredFontManager == self.preferredFontManager && textStyle == self.textStyle {
            self.updateFont()
        }
    }

    @objc private func contentSizeCategoryDidChange(notification: Notification) {
        self.updateFont()
    }

}
