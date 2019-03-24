//
//  ImageScrollView.swift
//  Block
//
//  Created by Jakub on 11/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    
    static var Problem = BlockProblem()
    
    var Shapes: [CAShapeLayer] = []
    var Paths: [UIBezierPath] = []
    
    var zoomView: UIImageView!
    
    lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap(_:)))
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollView.DecelerationRate.fast
        self.delegate = self
        
        
        // AUTO GENERATED BY: ssvgparser.py
        for ShC in AutoGen.FromSVG.ShapesCoords {
            let Shape = CAShapeLayer()
            Shapes.append(Shape)
            let Path = UIBezierPath()
            Path.move(to: CGPoint(x: ShC[0].0, y: ShC[0].1))
            for Point in ShC.dropFirst() {
                Path.addLine(to: CGPoint(x: Point.0, y: Point.1))
            }
            Path.close()
            Paths.append(Path)
        }
        // END
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.centerImage()
    }
    
    //MARK: - Configure scrollView to display new image.
    func display(_ image: UIImage) {
        // clear the previous image
        zoomView?.removeFromSuperview()
        zoomView = nil
        // make a new UIImageView for the new image
        zoomView = UIImageView(image: image)
        self.addSubview(zoomView)
        
        self.configureFor(image.size)
        
        // AUTO GENERATED BY: ssvgparser.py
        for (Sh, P) in zip(Shapes, Paths) {
            zoomView.layer.addSublayer(Sh)
            Sh.opacity = 0
            Sh.lineWidth = 4
            Sh.lineJoin = CAShapeLayerLineJoin.miter
            Sh.strokeColor = Defs.RedStroke.cgColor
            Sh.fillColor = Defs.RedFill.cgColor
            Sh.path = P.cgPath
        }
        // END
    }
    
    func configureFor(_ imageSize: CGSize) {
        self.contentSize = imageSize
        self.setMaxMinZoomScaleForCurrentBounds()
        self.zoomScale = self.minimumZoomScale
        //Enable zoom tap
        self.zoomView.addGestureRecognizer(self.zoomingTap)
        self.zoomView.isUserInteractionEnabled = true
    }
    
    func setMaxMinZoomScaleForCurrentBounds() {
        let boundsSize = self.bounds.size
        let imageSize = zoomView.bounds.size
        
        // calculate minimumZoomscale
        let xScale =  boundsSize.width  / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        self.maximumZoomScale = 5.0
        self.minimumZoomScale = minScale
    }
    
    func centerImage() {
        // center the zoom view as it becomes smaller than the size of the screen
        let boundsSize = self.bounds.size
        var frameToCenter = zoomView?.frame ?? CGRect.zero
        
        // center horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width)/2
        }
        else {
            frameToCenter.origin.x = 0
        }
        // center vertically
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height)/2 - topbarHeight
        }
        else {
            frameToCenter.origin.y = 0 - topbarHeight
        }
        
        zoomView?.frame = frameToCenter
    }
    
    //MARK: - UIScrollView Delegate Methods.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.zoomView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImage()
    }
    
    @objc func handleZoomingTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        self.zoom(to: location, animated: true)
    }
    
    func zoom(to point: CGPoint, animated: Bool) {
        let currentScale = self.zoomScale
        let minScale = self.minimumZoomScale
        let maxScale = self.maximumZoomScale
        
        if (minScale == maxScale && minScale > 1) {
            return;
        }
        let toScale = maxScale
        let finalScale = (currentScale == minScale) ? toScale : minScale
        let zoomRect = self.zoomRect(for: finalScale, withCenter: point)
        self.zoom(to: zoomRect, animated: animated)
    }
    
    // The center should be in the imageView's coordinates
    func zoomRect(for scale: CGFloat, withCenter center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let bounds = self.bounds
        
        // the zoom rect is in the content view's coordinates.
        //At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
        //As the zoom scale decreases, so more content is visible, the size of the rect grows.
        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale
        
        // choose an origin so as to get the right center.
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
    func setUpSegmentedControl(elements: [String], yOffset: CGFloat, isHidden: Bool = false) -> UISegmentedControl {
        let control = UISegmentedControl(items: elements)
        control.layer.borderColor = Defs.DarkRed.cgColor
        control.tintColor = Defs.DarkRed
        control.backgroundColor = Defs.White.withAlphaComponent(0.5)
        control.frame = CGRect(x: frame.minX + 10, y: frame.maxY - yOffset,
                               width: frame.maxX - 20, height: 40)
        control.isHidden = isHidden
        control.layer.cornerRadius = 15.0
        control.layer.borderWidth = 1.0
        control.layer.masksToBounds = true
        control.isMomentary = true
        
        return control
    }
    
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}

extension UIScrollView {
    /**
     *  Height of status bar + navigation bar (if navigation bar exist)
     */
    var topbarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height + 11.5
        // (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}
