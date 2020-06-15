 //  Created by Joel Trew on 24/04/2016.
 import MapKit
 /// Draws a given polyline with a gradient fill, use in place of a MKOverlayPathRenderer
 class GradientPathRenderer: MKOverlayPathRenderer {
    /// The polyline to render
    var polyline: MKPolyline
    /// The colors used to draw the gradient
    var colors: [UIColor]
    /// If a border should be rendered to make the line more visible
    var showsBorder: Bool = false
    /// The color of tne border, if showsBorder is true
    var borderColor: UIColor?
    /// Convenience to get an array of CGcolours from UIColors
    private var cgColors: [CGColor] {
        return colors.map({ (color) -> CGColor in
            return color.cgColor
        })
    }
    //MARK: Initializers
    /// Initializes a new Gradient Path Renderer from a given polyline and an array of colors
    ///
    /// - Parameters:
    ///   - polyline: The polyline to render
    ///   - colors: The colours the gardient should contain
    init(polyline: MKPolyline, colors: [UIColor], showsBorder: Bool) {
        self.polyline = polyline
        self.colors = colors
        self.showsBorder = showsBorder
        super.init(overlay: polyline)
    }
    /// Initializes a new Gradient Path Renderer from a given polyline and an array of colors, with a border with a defined colour
    ///
    /// - Parameters:
    ///   - polyline: The polyline to render
    ///   - colors: The colours the gardient should contain
    ///   - showsBorder: If the polyline should have a border
    ///   - borderColor: The colour of the border
    init(polyline: MKPolyline, colors: [UIColor], showsBorder: Bool, borderColor: UIColor) {
        self.polyline = polyline
        self.colors = colors
        self.showsBorder = showsBorder
        self.borderColor = borderColor
        super.init(overlay: polyline)
    }
    //MARK: Override methods
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        /*
         Set path width relative to map zoom scale
         */
        let baseWidth: CGFloat = self.lineWidth / zoomScale
        if self.showsBorder {
            context.setLineWidth(baseWidth * 2)
            context.setLineJoin(CGLineJoin.round)
            context.setLineCap(CGLineCap.round)
            context.addPath(self.path)
            context.setStrokeColor(self.borderColor?.cgColor ?? UIColor.white.cgColor)
            context.strokePath()
        }
        /*
         Create a gradient from the colors provided with evenly spaced stops
         */
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let stopValues = calculateNumberOfStops()
        let locations: [CGFloat] = stopValues
        let gradient = CGGradient(colorsSpace: colorspace, colors: cgColors as CFArray, locations: locations)
        /*
         Define path properties and add it to context
         */
        context.setLineWidth(baseWidth)
        context.setLineJoin(CGLineJoin.round)
        context.setLineCap(CGLineCap.round)
        context.addPath(self.path)
        /*
         Replace path with stroked version so we can clip
         */
        context.saveGState();
        context.replacePathWithStrokedPath()
        context.clip();
        /*
         Create bounding box around path and get top and bottom points
         */
        let boundingBox = self.path.boundingBoxOfPath
        let gradientStart = boundingBox.origin
        let gradientEnd   = CGPoint(x:boundingBox.maxX, y:boundingBox.maxY)
        /*
         Draw the gradient in the clipped context of the path
         */
        if let gradient = gradient {
            context.drawLinearGradient(gradient, start: gradientStart, end: gradientEnd, options: CGGradientDrawingOptions.drawsBeforeStartLocation);
        }
        context.restoreGState()
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
    /*
     Create path from polyline
     Thanks to Adrian Schoenig
     (http://adrian.schoenig.me/blog/2013/02/21/drawing-multi-coloured-lines-on-an-mkmapview/ )
     */
    /*override func createPath() {
        let path: CGMutablePath  = CGMutablePath()
        var pathIsEmpty: Bool = true
        for i in 0...self.polyline.pointCount-1 {
            let point: CGPoint = self.point(for: self.polyline.points()[i])
            if pathIsEmpty {
                path.move(to: point)
                pathIsEmpty = false
            } else {
                path.addLine(to: point)
            }
        }
        self.path = path
    }*/
    override func createPath() {
     // Getting the coordinates from the polyline
     let points = polyline.points()
     // Taking the center of the polyline (between the 2 coordiantes) and converting to CGPoint
     let centerMapPoint = MKMapPoint(polyline.coordinate)
     // Converting coordinates to CGPoint corresponding to the specified point on the map
     let startPoint = point(for: points[0])
     let endPoint = point(for: points[1])
     let centerPoint = point(for: centerMapPoint)
     // I would like to thank a co-worker of mine for the controlPoint formula :)
     let controlPoint = CGPoint(x: centerPoint.x + (startPoint.y - endPoint.y) / 3,
                                y: centerPoint.y + (endPoint.x - startPoint.x) / 3)
     // Defining our new curved path using Bezier path
     let myPath = UIBezierPath()
     myPath.move(to: startPoint)
     myPath.addQuadCurve(to: endPoint,
                         controlPoint: controlPoint)
     // Mutates the solid line with our curved one
     path = myPath.cgPath
    }
    //MARK: Helper Methods
    private func calculateNumberOfStops() -> [CGFloat] {
        let stopDifference = (1 / Double(cgColors.count))
        return Array(stride(from: 0, to: 1+stopDifference, by: stopDifference))
            .map { (value) -> CGFloat in
                return CGFloat(value)
        }
    }
 }
