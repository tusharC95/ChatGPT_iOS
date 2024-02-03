//
//  ViewController.swift
//  ChatGPT_iOS
//
//  Created by DocomoDeveloper on 07/07/23.
//

import UIKit

class ViewController: UIViewController, GPTResponseDelegate {
    
    @IBOutlet weak var txtViewQuery: UITextView!
    
    @IBOutlet weak var txtViewGPTResponse: UITextView!
    
    var network: Network?
    
    var initResponse: TranslationResponse = TranslationResponse(id: "id", object: "object", created: 1, choices: [TranslationResponse.TextCompletionChoice(index: 0, message: Messages(role: "", content: ""), finish_reason: "Stop")])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtViewQuery.isScrollEnabled = true
        txtViewGPTResponse.isScrollEnabled = true
        
        network = Network(response: initResponse)
        network?.gptResponseDelegate = self
    }
    
    @IBAction func btnAskQuery(_ sender: Any) {
        if !txtViewQuery.text.isEmpty {
            network!.prompt = txtViewQuery.text!
            network!.getResponse()
            txtViewQuery.isEditable = false
            txtViewQuery.textColor = .darkGray
        }
    }
    
    func responseSuccess(assistantResponse: String) {
        txtViewGPTResponse.text! = assistantResponse
        
        txtViewQuery.isEditable = true
        txtViewQuery.textColor = .white
    }
    
    func responseFail(error: String) {
        DispatchQueue.main.sync {
            txtViewGPTResponse.text! = error
            
            txtViewQuery.isEditable = true
            txtViewQuery.textColor = .white
        }
    }
    
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
