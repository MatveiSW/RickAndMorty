//
//  CharactersViewController.swift
//  RickAndMorty
//
//  Created by Матвей Авдеев on 10.10.2023.
//

import UIKit

class CharactersViewController: UIViewController {

    private let networkManager = NetworkManager.shared
    private let identifier = "characterCell"
    private var rickAndMorty: RickAndMorty?

    private lazy var characterCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let collectionViewWidth = view.frame.width
        let itemWidth = (collectionViewWidth - 50) / 2
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: itemWidth, height: 220)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(CharacterViewCell.self, forCellWithReuseIdentifier: identifier)
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = UIColor(named: "backgroundColor")
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCharacterCollectionView()
        fetchRickAndMorty()
        settingNavigationBar()
      
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let infoCharacterVC = InfoCharacterViewController()
        let character = rickAndMorty?.results[indexPath.row]
        infoCharacterVC.characterNameLabel.text = character?.name
        networkManager.fetchCharacterImage(withUrl: character?.image ?? Link.rickAndMorty.url, image: infoCharacterVC.characterImageView)
        infoCharacterVC.character = character
        
        navigationController?.pushViewController(infoCharacterVC, animated: true)
    }

   private func fetchRickAndMorty() {
        networkManager.fetchRickAndMorty(RickAndMorty.self, withUrl: Link.rickAndMorty.url) { [weak self] result in
            switch result {
            case .success(let rickAndMortyData):
                self?.rickAndMorty = rickAndMortyData
                
                DispatchQueue.main.async {
                    self?.characterCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func settingNavigationBar() {
        title = "Characters"
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(named: "backgroundColor")
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next>>", style: .done, target: self, action: #selector(nextButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<<Prev", style: .done, target: self, action: #selector(prevButton))
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "nextButtonColor")
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "prevButtonColor")
    }
    
    private func addCharacterCollectionView() {
        view.addSubview(characterCollectionView)
        NSLayoutConstraint.activate(
            [
                characterCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                characterCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                characterCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                characterCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }
    
    @objc private func nextButton() {
        if rickAndMorty?.info.next != nil {
            networkManager.fetchRickAndMorty(RickAndMorty.self, withUrl: rickAndMorty?.info.next ?? Link.rickAndMorty.url) { [weak self] result in
                switch result {
                case .success(let rickAndMortyData):
                    self?.rickAndMorty = rickAndMortyData
                    DispatchQueue.main.async {
                        self?.characterCollectionView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @objc private func prevButton() {
        if rickAndMorty?.info.prev != nil {
            networkManager.fetchRickAndMorty(RickAndMorty.self, withUrl: rickAndMorty?.info.prev ?? Link.rickAndMorty.url) { [weak self] result in
                switch result {
                case .success(let rickAndMortyData):
                    self?.rickAndMorty = rickAndMortyData
                    DispatchQueue.main.async {
                        self?.characterCollectionView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

extension CharactersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        rickAndMorty?.results.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? CharacterViewCell else { return UICollectionViewCell() }
        cell.configure(character: rickAndMorty?.results[indexPath.row])
        cell.backgroundColor = UIColor(named: "cellColor")
        cell.layer.cornerRadius = 20
        
        return cell
    }
    
    
}
