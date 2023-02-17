//
//  ViewController.swift
//  webViewReview
//
//  Created by Amel Sbaihi on 11/21/22.
//

import UIKit
import WebKit

// delegation design pattern : it is a way of writing code it is extensivly used in ios
// a delegate is one thing acting in place of another effectively answering questions and responding to events
// in our example we are using wkWebVire , but as smart is wkWebView is . it doesnt know or care how our application wants to behave . or which view controller is going to use it , because this is our custome code  so the delegation solution is brilliante
// our view controller sets itself as the delegate : webView.navigationDelegate = self
// which means when any navigation happens please tell me the view controller
// so the webView needs to make sure that the view controller can handell being the delegate so it will impose that the vc conforms to the the protocol and implment its methods
// in our case all the methods are optionals which means they will implement the default behavior


// KVO : What is it ? it is like please tell me when proprety x of object y gets changed by anyone at any time

// now let's refactor the code


class ViewController: UIViewController , WKNavigationDelegate {
    
    var  webView : WKWebView!
    
    var progressBar : UIProgressView!
    
    let websites = ["yahoo.com", "facebook.com"]
    
    // Mark : LoadView  Function
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    
    
    // Mark : ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let url = URL(string: "https://www."+websites[0]) else {return }
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "OPEN", style: .plain, target: self, action: #selector(openTapped))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.sizeToFit()
        
        let progress = UIBarButtonItem(customView: progressBar)
        
        navigationController?.isToolbarHidden = false
    toolbarItems = [progress, spacer, refresh]
        
        webView.addObserver(self , forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new ,context: nil)
    
        
    }
    
    // Mark : openTapped function
    
    @objc func openTapped ()
    {
        let ac = UIAlertController(title: "openWeb", message: nil, preferredStyle: .actionSheet)
        for website in websites{
            ac.addAction(UIAlertAction(title: website , style: .default, handler: openPage))
        }
       
        ac.addAction(UIAlertAction(title: "CANCEL", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(ac, animated: true)
        

    }
    
    // Mark : OpenPage Function
    
    func openPage (action : UIAlertAction)
    {
        guard let actionTitle = action.title else {return}
        guard let url = URL(string: "https://www."+(actionTitle) )else {return}
        webView.load(URLRequest(url: url))
        
        }
    
    // Mark didFinish function
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressBar.progress = Float(webView.estimatedProgress)
        }
    }
    
    // Mark : didDecidePolicy
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let url = navigationAction.request.url
        if let host = url?.host {
            
            for website in websites {
                
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        decisionHandler(.cancel)
        
    }
}

