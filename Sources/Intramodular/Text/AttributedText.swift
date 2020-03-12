//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct AttributedText: AppKitOrUIKitViewRepresentable {
    public typealias AppKitOrUIKitViewType = AppKitOrUIKitLabel
    
    public let content: NSAttributedString
    
    fileprivate var uiFont: UIFont?
    
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    @Environment(\.allowsTightening) var allowsTightening
    @Environment(\.font) var font
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.lineBreakMode) var lineBreakMode
    @Environment(\.lineLimit) var lineLimit
    @Environment(\.minimumScaleFactor) var minimumScaleFactor
    @Environment(\.preferredMaximumLayoutWidth) var preferredMaximumLayoutWidth
    
    #if os(macOS)
    @Environment(\.layoutDirection) var layoutDirection
    #endif
    
    public init(_ content: NSAttributedString) {
        self.content = content
    }
    
    public init<S: StringProtocol>(_ content: S) {
        self.init(NSAttributedString(string: String(content)))
    }
    
    public func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        AppKitOrUIKitViewType()
    }
    
    public func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        view.configure(with: self)
    }
}

// MARK: - API -

extension AttributedText {
    public func font(_ uiFont: UIFont) -> AttributedText {
        then({ $0.uiFont = uiFont })
    }
}
// MARK: - Helpers -

extension AppKitOrUIKitLabel {
    func configure(with attributedText: AttributedText) {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        self.allowsDefaultTighteningForTruncation = attributedText.allowsTightening
        #endif
        
        self.lineBreakMode = attributedText.lineBreakMode
        self.minimumScaleFactor = attributedText.minimumScaleFactor
        self.numberOfLines = attributedText.lineLimit ?? 0
        
        #if os(macOS)
        self.setAccessibilityEnabled(attributedText.accessibilityEnabled)
        self.userInterfaceLayoutDirection = .init(attributedText.layoutDirection)
        #endif
        
        if let uiFont = attributedText.uiFont {
            let string = NSMutableAttributedString(attributedString: attributedText.content)
            
            string.addAttribute(.font, value: uiFont, range: .init(location: 0, length: string.length))
            
            self.attributedText = attributedText.content
        } else {
            self.attributedText = attributedText.content
        }
        
        if let preferredMaximumLayoutWidth = attributedText.preferredMaximumLayoutWidth, preferredMaxLayoutWidth != attributedText.preferredMaximumLayoutWidth {
            preferredMaxLayoutWidth = preferredMaximumLayoutWidth
            
            frame.size.width = min(frame.size.width, preferredMaximumLayoutWidth)
            
            layoutIfNeeded()
        }
                
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
    }
}

private class AppKitOrUIKitLabelWrapper: AppKitOrUIKitView {
    private var label = AppKitOrUIKitLabel()
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(label)
        
        #if os(macOS)
        label.autoresizingMask = [.width, .height]
        #else
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #endif
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    #if !os(macOS)
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    #endif
    
    func configure(with attributedText: AttributedText) {
        label.configure(with: attributedText)
    }
}

#endif
