//
//  GoogleMapView.swift
//  StreetCare
//
//  Created by Amey Kanunje on 10/15/24.
//

import SwiftUI
import GoogleMaps

struct GoogleMapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 42.333774, longitude: -71.064937, zoom: 11)
        let mapView = GMSMapView(frame: .zero)
        mapView.camera = camera
        mapView.mapType = .normal
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.delegate = context.coordinator
        mapView.settings.compassButton = true

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let zoomInButton = UIButton()
        zoomInButton.translatesAutoresizingMaskIntoConstraints = false
        zoomInButton.backgroundColor = .white
        zoomInButton.setTitle("+", for: .normal)
        zoomInButton.setTitleColor(.black, for: .normal)
        zoomInButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
        zoomInButton.layer.cornerRadius = 2
        zoomInButton.layer.shadowColor = UIColor.black.cgColor
        zoomInButton.layer.shadowOpacity = 0.3
        zoomInButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        zoomInButton.addTarget(context.coordinator, action: #selector(Coordinator.zoomIn), for: .touchUpInside)

        let zoomOutButton = UIButton()
        zoomOutButton.translatesAutoresizingMaskIntoConstraints = false
        zoomOutButton.backgroundColor = .white
        zoomOutButton.setTitle("-", for: .normal)
        zoomOutButton.setTitleColor(.black, for: .normal)
        zoomOutButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
        zoomOutButton.layer.cornerRadius = 2
        zoomOutButton.layer.shadowColor = UIColor.black.cgColor
        zoomOutButton.layer.shadowOpacity = 0.3
        zoomOutButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        zoomOutButton.addTarget(context.coordinator, action: #selector(Coordinator.zoomOut), for: .touchUpInside)

        containerView.addSubview(zoomInButton)
        containerView.addSubview(zoomOutButton)
        mapView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -5),
            containerView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
            containerView.widthAnchor.constraint(equalToConstant: 40),
            containerView.heightAnchor.constraint(equalToConstant: 100),
            zoomInButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            zoomInButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            zoomInButton.widthAnchor.constraint(equalToConstant: 40),
            zoomInButton.heightAnchor.constraint(equalToConstant: 40),
            zoomOutButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            zoomOutButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            zoomOutButton.widthAnchor.constraint(equalToConstant: 40),
            zoomOutButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        viewModel.mapView = mapView
        DispatchQueue.main.async {
              mapView.layer.cornerRadius = mapView.frame.height / 17
              mapView.layer.masksToBounds = true
              mapView.layer.borderWidth = 1
              mapView.layer.borderColor = UIColor.black.cgColor
          }

        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.clear()
//        for request in viewModel.helpRequests {
//            let marker = GMSMarker(position: request.location)
//            marker.title = request.helpType
//            marker.snippet = request.description
//            // defaults red marker
//            marker.map = mapView
//        }
        for event in viewModel.mapVisitLogs {
            let marker = GMSMarker(position: event.0)
            marker.title = event.1
            marker.snippet = event.2
            marker.map = mapView
        }

        for event in viewModel.outreachEvents {
            let marker = GMSMarker(position: event.location)
            marker.title = event.title
            marker.snippet = event.description
            if let customYellowMarker = createCustomYellowMarker() {
                marker.icon = customYellowMarker
            }
            marker.map = mapView
        }
        let defaultCamera = GMSCameraPosition.camera(withLatitude: 40.7590, longitude: -73.9690, zoom: 11)
        mapView.animate(to: defaultCamera)
    }
    
    func createCustomYellowMarker() -> UIImage? {
        let size = CGSize(width: 35, height: 45)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let circleRect = CGRect(x: (size.width - 20) / 2, y: 5, width: 20, height: 20)
            let circlePath = UIBezierPath(ovalIn: circleRect)
            UIColor(red: 1.0, green: 0.92, blue: 0.23, alpha: 1.0).setFill()
            circlePath.fill()
            
            circlePath.lineWidth = 1
            UIColor.black.setStroke()
            circlePath.stroke()
            
            let dotDiameter: CGFloat = 4
            let dotRect = CGRect(x: circleRect.midX - dotDiameter / 2,
                                 y: circleRect.midY - dotDiameter / 2,
                                 width: dotDiameter,
                                 height: dotDiameter)
            let dotPath = UIBezierPath(ovalIn: dotRect)
            UIColor.black.setFill()
            dotPath.fill()
            
            let trianglePath = UIBezierPath()
            trianglePath.move(to: CGPoint(x: size.width/2 - 7, y: circleRect.maxY + 2))
            trianglePath.addLine(to: CGPoint(x: size.width/2 + 7, y: circleRect.maxY + 2))
            trianglePath.addLine(to: CGPoint(x: size.width/2, y: size.height))
            trianglePath.lineWidth = 2
            UIColor.black.setStroke()
            trianglePath.stroke()
            trianglePath.close()
            UIColor(red: 1.0, green: 0.92, blue: 0.23, alpha: 1.0).setFill()
            trianglePath.fill()
        }
        return image
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }

    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView
        init(_ parent: GoogleMapView) { self.parent = parent }
        @objc func zoomIn() {
            guard let mapView = parent.viewModel.mapView else { return }
            mapView.animate(toZoom: mapView.camera.zoom + 1)
        }
        @objc func zoomOut() {
            guard let mapView = parent.viewModel.mapView else { return }
            mapView.animate(toZoom: mapView.camera.zoom - 1)
        }
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            return false
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8)*17, (int >> 4 & 0xF)*17, (int & 0xF)*17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
    }
}
