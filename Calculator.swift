//
//  Calculator.swift
//  CurrencyCalc
//
//  Created by Sven Lobbes on 16.02.22.
//

import Foundation
import UIKit

struct readcurrency: Codable{
    let rates: [String: Double]
}

class Calculator: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var pricelbl: UILabel!
    @IBOutlet weak var inputtxt: UITextField!
    @IBOutlet weak var pickerview: UIPickerView!
    
    var currencyCode: [String] = []
    var values: [Double] = []
    var activeCurrency = 0.0
    
    override func viewDidLoad() {
        pickerview.delegate = self
        pickerview.dataSource = self
        //DARKMODE
        overrideUserInterfaceStyle = .dark
        super.viewDidLoad()
        fetchJSON()
        inputtxt.addTarget(self, action: #selector(updateViews), for: .editingChanged)
    }
    
    @objc func updateViews(input: Double){
        guard let amountText = inputtxt.text, let theAmountText = Double(amountText) else { return }
        if inputtxt.text != ""{
            let total = theAmountText * activeCurrency
            pricelbl.text = String(format: "%.2f", total) + "€"
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyCode.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyCode[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activeCurrency = values[row]
        updateViews(input: activeCurrency)
    }
    
    func fetchJSON(){
     //   guard let url = URL(string: "https://open.exchangerate-api.com/v6/latest") else { return }
        guard let url = URL(string: "http://data.fixer.io/api/latest?access_key=4e7b10d0d10c65a2d6371ac4d640ec80&format=1") else { return }
        
                URLSession.shared.dataTask(with: url) { data, response, error in
                    //handle any errors if there any
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    //safely unwrap the dat a
                    guard let safeData = data else { return }
                    // decode the JSON DATA
                    do {
                        let results = try JSONDecoder().decode(readcurrency.self, from: safeData)
                        
                        //EXTRA IMPLEMENTATION
                        
                        var EXTRAARRAY: [String] = [""]
                        EXTRAARRAY.append(contentsOf: results.rates.keys)
                        
                        let userDefaults = UserDefaults.standard
                        userDefaults.set(EXTRAARRAY, forKey: "ALLCURRENCY")
                        
                        
                        self.currencyCode.append(contentsOf: results.rates.keys)
                        self.values.append(contentsOf: results.rates.values)
                        DispatchQueue.main.async{
                            self.pickerview.reloadAllComponents()
                            
                        }
                    } catch {
                        print(error)
                }
                }.resume()
    
    
    }

}
