//
//  Form.FlexBox.Builder.swift
//  Form
//
//  Created by Haider Khan on 7/13/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public protocol FlexBoxComponents {
    static func layout(display: Display,
                       positionType: PositionType,
                       direction: Direction,
                       flexDirection: FlexDirection,
                       flexWrap: FlexWrap,
                       overflow: Overflow,
                       alignItems: AlignItems,
                       alignSelf: AlignSelf,
                       alignContent: AlignContent,
                       justifyContent: JustifyContent,
                       position: Rect<Dimension>,
                       margin: Rect<Dimension>,
                       padding: Rect<Dimension>,
                       border: Rect<Dimension>,
                       flexGrow: Float32,
                       flexShrink: Float32,
                       flexBasis: Dimension,
                       size: Size<Dimension>,
                       minSize: Size<Dimension>,
                       maxSize: Size<Dimension>,
                       aspectRatio: Number) -> Self
    
    static func layout(position: Rect<Dimension>,
                       size: Size<Dimension>,
                       minSize: Size<Dimension>,
                       maxSize: Size<Dimension>,
                       aspectRatio: Float,
                       margin: Rect<Dimension>,
                       padding: Rect<Dimension>,
                       border: Rect<Dimension>) -> Self
}

public struct FlexBoxBuilder {
    let style: Style<Dimension>
    private init(style: Style<Dimension>) {
        self.style = style 
    }
}

extension FlexBoxBuilder: FlexBoxComponents {
    
    public static func layout(display: Display = .defaultValue,
                              positionType: PositionType = .defaultValue,
                              direction: Direction = .defaultValue,
                              flexDirection: FlexDirection = .defaultValue,
                              flexWrap: FlexWrap = .defaultValue,
                              overflow: Overflow = .defaultValue,
                              alignItems: AlignItems = .defaultValue,
                              alignSelf: AlignSelf = .defaultValue,
                              alignContent: AlignContent = .defaultValue,
                              justifyContent: JustifyContent = .defaultValue,
                              position: Rect<Dimension> = .zero,
                              margin: Rect<Dimension> = .zero,
                              padding: Rect<Dimension> = .zero,
                              border: Rect<Dimension> = .zero,
                              flexGrow: Float32 = 0.0,
                              flexShrink: Float32 = 1.0,
                              flexBasis: Dimension = .auto,
                              size: Size<Dimension> = .zero,
                              minSize: Size<Dimension> = .zero,
                              maxSize: Size<Dimension> = .zero,
                              aspectRatio: Number = .defined(0.0)) -> FlexBoxBuilder {
        return FlexBoxBuilder(style: Style(display: display,
                                           positionType: positionType,
                                           direction: direction,
                                           flexDirection: flexDirection,
                                           flexWrap: flexWrap,
                                           overflow: overflow,
                                           alignItems: alignItems,
                                           alignSelf: alignSelf,
                                           alignContent: alignContent,
                                           justifyContent: justifyContent,
                                           position: position,
                                           margin: margin,
                                           padding: padding,
                                           border: border,
                                           flexGrow: flexGrow,
                                           flexShrink: flexShrink,
                                           flexBasis: flexBasis,
                                           size: size,
                                           minSize: minSize,
                                           maxSize: maxSize,
                                           aspectRatio: aspectRatio))
    }
    
    public static func layout(position: Rect<Dimension> = .zero,
                              size: Size<Dimension>,
                              minSize: Size<Dimension> = .zero,
                              maxSize: Size<Dimension> = .zero,
                              aspectRatio: Float = 1.0,
                              margin: Rect<Dimension> = .zero,
                              padding: Rect<Dimension> = .zero,
                              border: Rect<Dimension> = .zero) -> FlexBoxBuilder {
        return FlexBoxBuilder(style: Style(display: .defaultValue,
                                           positionType: .defaultValue,
                                           direction: .defaultValue,
                                           flexDirection: .defaultValue,
                                           flexWrap: .defaultValue,
                                           overflow: .defaultValue,
                                           alignItems: .defaultValue,
                                           alignSelf: .defaultValue,
                                           alignContent: .defaultValue,
                                           justifyContent: .defaultValue,
                                           position: position,
                                           margin: margin,
                                           padding: padding,
                                           border: border,
                                           flexGrow: 0.0,
                                           flexShrink: 1.0,
                                           flexBasis: .auto,
                                           size: size,
                                           minSize: minSize == .zero ? size : minSize,
                                           maxSize: maxSize == .zero ? size : maxSize,
                                           aspectRatio: .defined(aspectRatio)))
    }
    
}
