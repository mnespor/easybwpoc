//
//  ViewController.swift
//  bwdemo
//
//  Created by Matthew Nespor on 6/24/19.
//  Copyright © 2019 Matthew Nespor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var colorPickerView: UIView!
  @IBOutlet weak var thumbView: UIView!
  @IBOutlet weak var imageView: UIImageView!

  private let inputImage = CIImage(image: UIImage(named: "lenna")!)!
  private let thingDoer = ThingDoer()

  @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .changed:
      thumbView.center = sender.location(in: sender.view)
    default:
      break
    }
  }

  private func updateImage() {
    if let ciimage = thingDoer.processedImage(inputImage) {
      imageView.image = UIImage(ciImage: ciimage)
    }
  }

  @IBAction func handleSlider(_ sender: UISlider) {
    thingDoer.hue = CGFloat(sender.value)
    updateImage()
  }

  @IBAction func handleVibranceToggle(_ sender: UISwitch) {
    thingDoer.levelsEnabled = sender.isOn
    updateImage()
  }

  @IBAction func handleVignetteAmount(_ sender: UISlider) {
    thingDoer.vignetteAmount = CGFloat(sender.value)
    updateImage()
  }

  @IBAction func handleShadowAmount(_ sender: UISlider) {
    thingDoer.shadowAmount = CGFloat(sender.value)
    updateImage()
  }

  @IBAction func handleHighlightAmount(_ sender: UISlider) {
    thingDoer.highlightAmount = CGFloat(sender.value)
    updateImage()
  }

  // Next up: Draw a sample image and apply a filter chain from ThingDoer.
  // Later: Cap the framerate.
  // Much later: Figure out the photoadjustmentdata handling

  // Use CIHueSaturationValueGradient to draw a color wheel:
  // https://noahgilmore.com/blog/cifilter-colorwheel/
}

