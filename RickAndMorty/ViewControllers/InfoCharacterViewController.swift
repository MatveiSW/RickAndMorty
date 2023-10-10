//
//  InfoCharacterViewController.swift
//  RickAndMorty
//
//  Created by Матвей Авдеев on 11.10.2023.
//

import UIKit

class InfoCharacterViewController: UIViewController {
    
    private let networkManager = NetworkManager.shared
    private let infoCellIdentifier = "infoCell"
    private let episodeCellIdentifier = "episodeCell"
    private var episode: [Episode] = []
    var character: Character?
    
    lazy var characterImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 20
        image.clipsToBounds = true
        return image
    }()
    
    lazy var characterNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .black)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var characterStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(characterImageView)
        stack.addArrangedSubview(characterNameLabel)
        stack.axis = .vertical
        return stack
    }()
    
    private lazy var characterTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: infoCellIdentifier)
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundColor")
        addCharacterStackView()
        addCharacterTableView()
        fetchEpisode()
    }
    
    private func addCharacterStackView() {
        view.addSubview(characterStackView)
        NSLayoutConstraint.activate(
            [
                characterStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                characterStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
                characterStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
                characterStackView.heightAnchor.constraint(equalToConstant: 220)
            ]
        )
    }
    
    private func addCharacterTableView() {
        view.addSubview(characterTableView)
        NSLayoutConstraint.activate(
            [
                characterTableView.topAnchor.constraint(equalTo: characterStackView.bottomAnchor, constant: 20),
                characterTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                characterTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                characterTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
            ]
        )
    }
    
    private func fetchEpisode() {
        guard let character = character else { return }

        var episodes = [Episode]()

        let group = DispatchGroup()

        for episodeUrl in character.episode {
            group.enter()
            networkManager.fetchRickAndMorty(Episode.self, withUrl: episodeUrl) { result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let episodeData):
                    episodes.append(episodeData)
                case .failure(let error):
                    print(error)
                }
            }
        }

        group.notify(queue: .main) {
            self.episode = episodes
            self.characterTableView.reloadData()
        }
    }


    
}

extension InfoCharacterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : character?.episode.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: infoCellIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        cell.backgroundColor = UIColor(named: "cellColor")
        if indexPath.section == 0 {
            content.text = character?.description
        } else if indexPath.section == 1 && indexPath.row < episode.count {
            content.text = episode[indexPath.row].description
        }

        content.textProperties.color = .white
        content.textProperties.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        cell.layer.cornerRadius = 20
        cell.selectionStyle = .none
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Info" : "Episode"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = UIColor.white
            headerView.textLabel?.font = .boldSystemFont(ofSize: 15)
        }
    }

    
}
