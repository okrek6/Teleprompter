//
//  TeleprompterViewController.swift
//  Teleprompter
//
//  Created by Krekeler, Brendan F. (MU-Student) on 4/16/19.
//  Copyright © 2019 Krekeler, Brendan F. (MU-Student). All rights reserved.
//

import UIKit

class TeleprompterViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    var minWidth: CGFloat = 0.0
    var maxWidth: CGFloat = 0.0
    var currentWidth: CGFloat = 0.0
    var initialWidth: CGFloat = 0.0
    
    var displayText = ""
    var scrollTimer: Timer?
    
    var scrollState = Scroll.stopped
    
    var currentCount = 0
    var bottomCount = 0
    
    var bottomOffset: CGFloat = 0.0
    var currentOffset: CGFloat = 0.0
    
    //var orientations = [Orientation(x: 1, y: 1), Orientation(x: 1, y: -1), Orientation(x: -1, y: 1), Orientation(x: -1, y: -1)]
    var orientations = [Orientation(x: 1, y: 1), Orientation(x: 1, y: -1)]
    
    var currentOrientationIndex = 0
    
    
    @IBAction func pinchZoom(_ sender: UIPinchGestureRecognizer) {
        //sender.scale
        print(sender.scale)
        
        currentWidth = initialWidth * sender.scale
        if (currentWidth > maxWidth) {
            currentWidth = maxWidth
        } else if (currentWidth < minWidth) {
            currentWidth = minWidth
        }
        
        let edgeOffsetWidth = (maxWidth - currentWidth) / 2.0
        
        
    }
    
    @IBAction func dragLeftEdge(_ sender: UIPanGestureRecognizer) {
        print(sender.translation(in: view).x)
        
        let offset = sender.translation(in: view).x
        currentWidth = currentWidth - (offset * 2.0)
        
        if (currentWidth > maxWidth) {
            currentWidth = maxWidth
        } else if (currentWidth < minWidth) {
            currentWidth = minWidth
        }
        
        let edgeOffsetWidth = (maxWidth - currentWidth) / 2.0
        
        
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @IBAction func dragRightEdge(_ sender: UIPanGestureRecognizer) {
        print(sender.translation(in: view).x)
        
        let offset = -(sender.translation(in: view).x)
        currentWidth = currentWidth - (offset * 2.0)
        
        if (currentWidth > maxWidth) {
            currentWidth = maxWidth
        } else if (currentWidth < minWidth) {
            currentWidth = minWidth
        }
        
        let edgeOffsetWidth = (maxWidth - currentWidth) / 2.0
        
        
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        initialWidth = textView.bounds.width
        currentWidth = initialWidth
        maxWidth = view.bounds.width
        minWidth = maxWidth / 3.0
        
        let orientation = orientations[currentOrientationIndex]
        
        textView.transform = CGAffineTransform(scaleX: orientation.x, y: orientation.y)
        
        rightLabel.text = "normal"
        
        
        
        //textView.text = ""
        
        //let bottom = textView.contentSize.height
        //textView.setContentOffset(CGPoint(x: 0, y: bottom), animated: true) // Scrolls to end
    }
    
    override func viewDidLayoutSubviews() {
        //setupScroll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupScroll()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentOffset = scrollView.contentOffset.y
    }
    
    
    @IBAction func start(_ sender: Any) {
        startScroll()
    }
    
    @IBAction func pause(_ sender: Any) {
        pauseScroll()
    }
    
    @IBAction func stop(_ sender: Any) {
        stopScroll()
    }
    
    @IBAction func flip(_ sender: Any) {
        currentOrientationIndex += 1
        if (currentOrientationIndex >= orientations.count) {
            currentOrientationIndex = 0
        }
        
        let orientation = orientations[currentOrientationIndex]
        
        textView.transform = CGAffineTransform(scaleX: orientation.x, y: orientation.y)
        
        if (orientation.y == -1) {
            rightLabel.text = "mirrored"
        } else {
            rightLabel.text = "normal"
        }
    }
    
    func startScroll() {
        if (scrollState == .paused) {
            scrollState = .running
        } else {
            //startRangeScroll()
            startOffsetScroll()
        }
    }
    
    func pauseScroll() {
        scrollState = .paused
    }
    
    func stopScroll() {
        // stopRangeScroll()
        stopOffsetScroll()
    }
    
    func setupScroll() {
        self.bottomOffset = textView.contentSize.height
        let textViewHeight = textView.bounds.height
        self.currentOffset = -(textViewHeight/2)
        self.leftLabel.text = "\(self.currentOffset)"
        self.middleLabel.text = "\(self.bottomOffset)"
        self.textView.setContentOffset(CGPoint(x: 0, y: self.currentOffset), animated: false)
    }
    
    func startOffsetScroll() {
        /*self.bottomOffset = textView.contentSize.height
         let textViewHeight = textView.bounds.height
         self.currentOffset = -(textViewHeight/2)
         self.leftLabel.text = "\(self.currentOffset)"
         self.middleLabel.text = "\(self.bottomOffset)"
         self.textView.setContentOffset(CGPoint(x: 0, y: self.currentOffset), animated: false)
         */
        
        setupScroll()
        
        self.scrollTimer?.invalidate()
        
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true, block: {
            (timer) in
            if (self.scrollState == .paused) { return }
            self.currentOffset += 0.5
            if (self.currentOffset > self.bottomOffset) {
                self.scrollTimer?.invalidate()
                self.scrollState = .stopped
                return
            }
            self.leftLabel.text = "\(self.currentOffset)"
            self.textView.setContentOffset(CGPoint(x: 0, y: self.currentOffset), animated: false)
            
            //self.textView.scrollRangeToVisible(CGPoint(x: 0, y: self.currentOffset), animated: true)
        })
    }
    
    func stopOffsetScroll() {
        scrollTimer?.invalidate()
        self.scrollState = .stopped
        setupScroll()
    }
    
    func startRangeScroll() {
        self.bottomCount = textView.text.count
        self.currentCount = 0
        
        self.scrollTimer?.invalidate()
        
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true, block: {
            (timer) in
            if (self.scrollState == .paused) { return }
            self.currentCount += 1
            if (self.currentCount > self.bottomCount) {
                self.scrollTimer?.invalidate()
                self.scrollState = .stopped
                return
            }
            self.leftLabel.text = "\(self.currentCount)"
            let range = NSMakeRange(self.currentCount, 1)
            self.textView.scrollRangeToVisible(range)
        })
    }
    
    func stopRangeScroll() {
        scrollTimer?.invalidate()
        self.scrollState = .stopped
        
        setupScroll()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
