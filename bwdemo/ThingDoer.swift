//
//  ThingDoer.swift
//  bwdemo
//
//  Created by Matthew Nespor on 6/24/19.
//  Copyright © 2019 Matthew Nespor. All rights reserved.
//

import UIKit
import CoreImage

class ThingDoer: NSObject {
  // TODO:
  // Usability
  // Performance (throttling + perform manipulations in background)
  // Photo extension
  // Refactoring

  // Image pipeline:
  // - Use the color picker to set a color coefficient for each channel.
  //   By default, multiply green and blue by 0.0 and red by 1.0.
  // - Desaturate the image.
  // - From the desaturated image, set the levels so that the low point
  //   is above the darkest 1 percent of pixels and the high point is
  //   above the lightest 1 percent.
  //   - vibrance: No effect on black and white image.
  //   - highlight-shadow: Good results on shadows, but no ability to blow out highlights.
  //   - gamma: Can't adjust shadows and highlights separately; it's easy to blow out and chunk at the same time
  //   - tone curve:
  // - Apply vignetting. Circular only, at least to start.
  //    https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_filer_recipes/ci_filter_recipes.html#//apple_ref/doc/uid/TP30001185-CH4-SW1

  let colorMatrixFilter = CIFilter(name: "CIColorMatrix")!
  let toneCurveFilter = CIFilter(name: "CIToneCurve")!
  let vignetteFilter = CIFilter(name: "CIVignette")!

  var hue: CGFloat = 0.0
  var vignetteRadius: CGFloat = 1.0
  var vignetteAmount: CGFloat = 0.0
  var levelsEnabled: Bool = true
  var shadowAmount: CGFloat = 1.0
  var highlightAmount: CGFloat = 1.0
  var gammaAmount: CGFloat = 1.0

  private func monochromeColorVector() -> CIVector {
    let hsvColor = UIColor(hue: self.hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    var r: CGFloat = 0.0
    var g: CGFloat = 0.0
    var b: CGFloat = 0.0
    hsvColor.getRed(&r, green: &g, blue: &b, alpha: nil)
    return CIVector(x: r, y: g, z: b, w: 0.0)
  }

  func processedImage(_ image: CIImage) -> CIImage? {
    colorMatrixFilter.setValue(image, forKey: kCIInputImageKey)
    let alphaVector = CIVector(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
    let colorVector = monochromeColorVector()
    colorMatrixFilter.setValue(colorVector, forKey: "inputRVector")
    colorMatrixFilter.setValue(colorVector, forKey: "inputGVector")
    colorMatrixFilter.setValue(colorVector, forKey: "inputBVector")
    colorMatrixFilter.setValue(alphaVector, forKey: "inputAVector")
    toneCurveFilter.setValue(CIVector(x: shadowAmount, y: 0.0), forKey: "inputPoint0")
    toneCurveFilter.setValue(CIVector(x: 0.25 + (shadowAmount * 0.5), y: 0.25), forKey: "inputPoint1")
    toneCurveFilter.setValue(CIVector(x: (shadowAmount - highlightAmount + 1) * 0.5, y: 0.5), forKey: "inputPoint2")
    toneCurveFilter.setValue(CIVector(x: 0.75 - (highlightAmount * 0.5), y: 0.75), forKey: "inputPoint3")
    toneCurveFilter.setValue(CIVector(x: 1.0 - highlightAmount, y: 1.0), forKey: "inputPoint4")
    if levelsEnabled {
      let randoFilters = colorMatrixFilter.outputImage?.autoAdjustmentFilters() ?? []
      let randoFilter = randoFilters[1]
      randoFilter.setValue(colorMatrixFilter.outputImage, forKey: kCIInputImageKey)
      vignetteFilter.setValue(randoFilter.outputImage, forKey: kCIInputImageKey)
    } else {
      vignetteFilter.setValue(colorMatrixFilter.outputImage, forKey: kCIInputImageKey)
    }

    vignetteFilter.setValue(vignetteAmount, forKey: kCIInputIntensityKey)
    vignetteFilter.setValue(vignetteRadius, forKey: kCIInputRadiusKey)

    return vignetteFilter.outputImage
  }
}
