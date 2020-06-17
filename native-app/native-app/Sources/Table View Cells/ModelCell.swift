//
//  ModelCell.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/15/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit

class ModelCell: UITableViewCell {
    
    private let namePlaceholderLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Name"
        label.textColor = .systemGray
        label.font = UIFont.preferredFont(forTextStyle: .body)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    private let nameTextView: UITextView = {
        let textView = UITextView()
        
        textView.textContainer.maximumNumberOfLines = 1
        textView.textContainer.lineBreakMode = .byTruncatingHead
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        
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
    
    private let urlPlaceholderLabel: UILabel = {
        let label = UILabel()
        
        label.text = "URL"
        label.textColor = .systemGray
        label.font = UIFont.preferredFont(forTextStyle: .body)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    
    private let urlTextView: UITextView = {
        let textView = UITextView()
        
        textView.textContainer.maximumNumberOfLines = 1
        textView.textContainer.lineBreakMode = .byTruncatingHead
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()
    
    var modelEndpoint: ModelEndpoint? {
        didSet {
            nameTextView.text = modelEndpoint?.name
            urlTextView.text = modelEndpoint?.url
            
            namePlaceholderLabel.text = modelEndpoint?.name == nil ? "Name" : " "
            urlPlaceholderLabel.text = modelEndpoint?.url == nil ? "URL" : " "
        }
    }
    
    var row: Int?
    
    weak var delegate: ModelCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameTextView.delegate = self
        urlTextView.delegate = self
        
        contentView.addSubview(namePlaceholderLabel)
        contentView.addSubview(nameTextView)
        contentView.addSubview(separatorView)
        contentView.addSubview(urlPlaceholderLabel)
        contentView.addSubview(urlTextView)
        
        separatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
        separatorView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        
        namePlaceholderLabel.leftAnchor.constraint(equalTo: nameTextView.leftAnchor, constant: 4.75).isActive = true
        namePlaceholderLabel.centerYAnchor.constraint(equalTo: nameTextView.centerYAnchor, constant: -0.5).isActive = true
        
        nameTextView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15).isActive = true
        nameTextView.rightAnchor.constraint(equalTo: separatorView.leftAnchor, constant: -15).isActive = true
        nameTextView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        nameTextView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        
        urlPlaceholderLabel.leftAnchor.constraint(equalTo: urlTextView.leftAnchor, constant: 4.75).isActive = true
        urlPlaceholderLabel.centerYAnchor.constraint(equalTo: urlTextView.centerYAnchor, constant: -0.5).isActive = true
        
        urlTextView.leftAnchor.constraint(equalTo: separatorView.rightAnchor, constant: 15).isActive = true
        urlTextView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15).isActive = true
        urlTextView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        urlTextView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        nameTextView.isEditable = editing
        urlTextView.isEditable = editing
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        
        separatorView.layer.sublayers?[0].frame = separatorView.bounds
        
        nameTextView.centerVertically()
        urlTextView.centerVertically()
    }

}

extension ModelCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == nameTextView {
            namePlaceholderLabel.text = textView.text.isEmpty ? "Name" : " "
            modelEndpoint?.name = textView.text
        } else if textView == urlTextView {
            urlPlaceholderLabel.text = textView.text.isEmpty ? "URL" : " "
            modelEndpoint?.url = textView.text
        }
        
        delegate?.modelCell(self, didChangeModel: modelEndpoint)
    }
    
}

protocol ModelCellDelegate: NSObject {
    
    func modelCell(_ modelCell: ModelCell, didChangeModel modelEndpoint: ModelEndpoint?)
    
}

extension UITextView {

    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }

}
