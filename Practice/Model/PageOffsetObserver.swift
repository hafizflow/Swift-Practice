//
//  PageOffsetObserver.swift
//  Practice
//
//  Created by Hafizur Rahman on 1/9/25.
//

import SwiftUI

@Observable
class PageOffsetObserver: NSObject {
    var collectionView: UICollectionView?
    var offset: CGPoint = .zero
    private(set) var isObserving: Bool = false
    
    deinit {
        remove()
    }
    
    func ovserve() {
            // Safe method
        guard !isObserving else { return }
        collectionView?.addObserver(self, forKeyPath: "contentOffset", context: nil)
        isObserving = true
    }
    
    func remove() {
        isObserving = false
        collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentOffset" else { return }
        
        if let contentOffset = (object as? UICollectionView)?.contentOffset {
            offset = contentOffset
        }
    }
}

struct FindCollectionView: UIViewRepresentable {
    var result: (UICollectionView) -> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let collectionView = view.collectionSuperview {
                print(collectionView)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
            // Update logic if needed
    }
}

extension UIView {
        // Finding the CollectionView by traversing the superview
    var collectionSuperview: UICollectionView? {
        if let collectionView = superview as? UICollectionView {
            return collectionView
        }
        return superview?.collectionSuperview
    }
}

