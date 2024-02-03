//
//  Model.swift
//  ChatGPT API
//
//  Created by giovanni russo on 01/03/23.
//

import Foundation
import UIKit

protocol GPTResponseDelegate {
    func responseSuccess(assistantResponse: String)
    func responseFail(error: String)
}
class Network: NSObject {
    
    var response: TranslationResponse
    var prompt: String = "Hello"
    
    //enter your API key here.
    let APIKEY = ""

    var gptResponseDelegate: GPTResponseDelegate?
    
    init(response: TranslationResponse){
        self.response = response
    }
    
    func getResponse() {
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            fatalError("Missing URL")
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "POST"
        
        urlRequest.addValue("Bearer " + APIKEY, forHTTPHeaderField: "Authorization")
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // You can edit the model, prompt, and role (See OpenAI/chat doc)
        // Default role is "user"
        let message = Messages(role: "user", content: prompt)
        
        let requestData = RequestData(model: "gpt-3.5-turbo", messages: [message])
        
        let encoder = JSONEncoder()
        
        guard let httpBody = try? encoder.encode(requestData) else {
            print("Error encoding JSON data")
            return
        }
        
        urlRequest.httpBody = httpBody
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    do {
                        let decodedResponse = try JSONDecoder().decode(TranslationResponse.self, from: data)
                        self.response = decodedResponse
                        self.gptResponseDelegate?.responseSuccess(assistantResponse: self.response.resultText)
                    } catch let error {
                        self.gptResponseDelegate?.responseFail(error: error.localizedDescription)
                    }
                }
            }
            else {
                self.gptResponseDelegate?.responseFail(error: response.description)
            }
        }
        dataTask.resume()
    }
}

struct RequestData: Codable {
    var model: String
    var messages: [Messages]
    
}
struct Messages: Codable {
    let role: String
    let content: String
}

struct TranslationResponse: Decodable {
    var id: String
    var object: String
    var created: Int
    var choices: [TextCompletionChoice]
    
    var resultText: String {
        choices.map(\.message.content).joined(separator: "\n")
    }
}

extension TranslationResponse {
    struct TextCompletionChoice: Decodable{
        var index: Int
        var message: Messages
        var finish_reason: String
    }
}
