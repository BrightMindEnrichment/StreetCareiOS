//
//  LoadingView.swift
//  StreetCare
//
//  Created by Michael Thornton on 4/29/22.
//

import UIKit

class LoadingView: UIView {
    
    private var labelText: UILabel?
    
    private var timeoutTimer: Timer?
    
    
    var text: String? {
        didSet {
            labelText?.text = text
        }
    }

    
    var done: Bool = false {
        didSet {
            if done {
                self.timeoutTimer?.invalidate()
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createUI()
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    
    
    func onTimeoutOf(_ seconds: Int, runTimeoutClosure timeout: @escaping () -> Void) {
        
        self.timeoutTimer = Timer.scheduledTimer(withTimeInterval: Double(seconds), repeats: false, block: { (timer) in
            timer.invalidate()
            timeout()
        })
    }

    
    
    func createUI() {
        
        self.backgroundColor = UIColor.clear
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        effectView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(effectView)
        //self.sendSubviewToBack(effectView)

        NSLayoutConstraint.activate([
            effectView.topAnchor.constraint(equalTo: self.topAnchor),
            effectView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            effectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])


        let spinner = UIActivityIndicatorView.init()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = UIColor.black
        self.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])

        spinner.startAnimating()
        
        
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.textAlignment = .center
        
        label.text = self.text ?? ""
        
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 8.0),
            label.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -16.0)
            ])
        
        self.labelText = label
    }
    
} // end class

