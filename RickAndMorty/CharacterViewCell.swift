//
//  CharacterViewCell.swift
//  RickAndMorty
//
//  Created by Матвей Авдеев on 10.10.2023.
//

import UIKit

class CharacterViewCell: UICollectionViewCell {
   
    private let networkManager = NetworkManager.shared
    
    lazy var characterImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 20
        image.clipsToBounds = true
        return image
    }()
    
    lazy var characterNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var characterStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.addArrangedSubview(characterImage)
        stack.addArrangedSubview(characterNameLabel)
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addCharacterStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(character: Character?) {
        characterNameLabel.text = character?.name
        networkManager.fetchCharacterImage(withUrl: character?.image ?? Link.rickAndMorty.url, image: characterImage)
    }
    
    private func addCharacterStackView() {
        contentView.addSubview(characterStackView)
        NSLayoutConstraint.activate(
            [
                characterStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                characterStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                characterStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                characterStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ]
        )
    }
}
