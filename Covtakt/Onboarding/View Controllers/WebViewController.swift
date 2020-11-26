//
//  WebViewController.swift
//  Covtakt
//
//  Created by IPification on 12/5/2020.
//  Copyright © 2020 OpenTrace. All rights reserved.
//

import Foundation
import WebKit
class WebViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var url: String = "https://covid19.who.int/"
    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.alwaysBounceHorizontal = false
        indicator.startAnimating()

        DispatchQueue.main.async {
            self.webView.load(URLRequest(url:URL(string: self.url)!))
        }
    }
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("failed")
        indicator.stopAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("success")
        indicator.stopAnimating()
    }
}
