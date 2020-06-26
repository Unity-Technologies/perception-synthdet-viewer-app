//
//  ModelCell.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/15/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit

class ModelCell: UITableViewCell {

    private let nameTextView: UITextField = {
        let textView = UITextField()
        
        textView.placeholder = "Name"
        
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.systemGray2.cgColor]
        view.layer.insertSublayer(gradient, at: 0)
        
        return view
    }()

    
    private let urlTextView: UITextField = {
        let textView = UITextField()

        textView.autocorrectionType = .no
        textView.placeholder = "URL"
        
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()
    
    var modelEndpoint: ModelEndpoint? {
        didSet {
            nameTextView.text = modelEndpoint?.name
            urlTextView.text = modelEndpoint?.url
        }
    }
    
    var row: Int?
    
    weak var delegate: ModelCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameTextView.delegate = self
        urlTextView.delegate = self
        
        contentView.addSubview(nameTextView)
        contentView.addSubview(separatorView)
        contentView.addSubview(urlTextView)
        
        separatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
        separatorView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        
        nameTextView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15).isActive = true
        nameTextView.rightAnchor.constraint(equalTo: separatorView.leftAnchor, constant: -15).isActive = true
        nameTextView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        nameTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        
        urlTextView.leftAnchor.constraint(equalTo: separatorView.rightAnchor, constant: 15).isActive = true
        urlTextView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15).isActive = true
        urlTextView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        urlTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        nameTextView.isUserInteractionEnabled = editing
        urlTextView.isUserInteractionEnabled = editing
        
        if !editing {
            nameTextView.endEditing(true)
            urlTextView.endEditing(true)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        
        separatorView.layer.sublayers?[0].frame = separatorView.bounds
    }
    
}

extension ModelCell: UITextFieldDelegate {
    
    func textFieldDidChange(_ textView: UITextView) {
        if textView == nameTextView {
            modelEndpoint?.name = textView.text
        } else if textView == urlTextView {
            modelEndpoint?.url = textView.text
        }
        
        delegate?.modelCell(self, didChangeModel: modelEndpoint)
    }
    
}

protocol ModelCellDelegate: NSObject {
    
    func modelCell(_ modelCell: ModelCell, didChangeModel modelEndpoint: ModelEndpoint?)
    
}
