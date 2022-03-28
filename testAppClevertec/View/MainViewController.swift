//
//  MainViewController.swift
//  testAppClevertec
//
//  Created by Apple on 18.03.22.
//

import UIKit

class MainViewController: UIViewController {
    var mainCollection: UICollectionView?
    let animatedСircle = LoadingCustomView()
    let headView = UIView()
    let refreshControl = UIRefreshControl()
    let searchController = UISearchController(searchResultsController: nil)
    var moviesList = [Movie]() {
        didSet {
            DispatchQueue.main.async {
                self.openMoviesList = self.moviesList
                self.refreshControl.endRefreshing()
                self.animatedСircle.isHidden = true
                self.animatedСircle.animationStop()
                self.connectionProblemsAlert()
                self.mainCollection?.reloadData()
            }
        }
    }
    var openMoviesList = [Movie]()
    var savedMovieIds = [Int]()
    struct Properties {
        static let cellName = "ListOfGamesViewCell"
        static let loadCircleSize: CGFloat = 50
        static let loadCircleBackgroundColor = UIColor.clear
        static let headViewBackgroundColor = UIColor.systemGray6.withAlphaComponent(0.2)
        static let headViewBorderWidth: CGFloat = 0.5
        static let headViewBorderColor = UIColor.systemGray4.cgColor
        static let mainCollectionBackgroundColor = UIColor.clear
        static let mainCollectionTopBottomInset: CGFloat = 10
        static let mainCollectionItemSideInsets: CGFloat = 20
        static let mainCollectionItemAspectRatio: CGFloat = 0.62
        static let searchBarTintColor = UIColor.lightGray
        
    }
    struct AlertConnection {
        static let title = "Something went wrong"
        static let buttonReload = "try again"
        static let buttonCancel = "cancel"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeadView()
        setMainCollection()
        registerMainCollection()
        setRefreshControl()
        setSearchController()
        getData()
        loadingAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        savedMovieIds = CoreDataManager.data.getSavedMovieIds()
        mainCollection?.reloadData()
    }
    
    func loadingAnimation() {
        guard let collection = mainCollection else {return}
        animatedСircle.backgroundColor = Properties.loadCircleBackgroundColor
        collection.addSubview(animatedСircle)
        animatedСircle.snp.makeConstraints { make in
            make.width.height.equalTo(Properties.loadCircleSize)
            make.centerX.centerY.equalTo(collection)
        }
    }
    
    func setHeadView() {
        headView.backgroundColor = Properties.headViewBackgroundColor
        headView.layer.borderWidth = Properties.headViewBorderWidth
        headView.layer.borderColor = Properties.headViewBorderColor
        view.addSubview(headView)
        headView.snp.makeConstraints { make in
            make.height.equalTo(searchController.searchBar.bounds.height)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalTo(view)
        }
    }
    
    func setRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        getData()
    }
    
    func setSearchController() {
        
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = Properties.searchBarTintColor
        headView.addSubview(searchController.searchBar)
    }
    
    func registerMainCollection() {
        mainCollection?.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: Properties.cellName)
        mainCollection?.delegate = self
        mainCollection?.dataSource = self
        mainCollection?.refreshControl = refreshControl
    }
    
    func setMainCollection() {
        let mainCollectionLayout = UICollectionViewFlowLayout()
        mainCollectionLayout.sectionInset.top = Properties.mainCollectionTopBottomInset
        mainCollectionLayout.sectionInset.bottom = Properties.mainCollectionTopBottomInset
        let itemWidth = self.view.frame.width - Properties.mainCollectionItemSideInsets
        let itemHeight = itemWidth * Properties.mainCollectionItemAspectRatio
        mainCollectionLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        mainCollection = UICollectionView(frame: self.view.bounds, collectionViewLayout: mainCollectionLayout)
        guard let collection = mainCollection else { return }
        collection.backgroundColor = Properties.mainCollectionBackgroundColor
        view.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.top.equalTo(headView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func getData() {
        NetworkManager.data.getAllData { [weak self] movies in
            self?.moviesList = movies
        }
    }
    
    func connectionProblemsAlert() {
        if moviesList.isEmpty {
            let alert = UIAlertController(title: AlertConnection.title, message: nil, preferredStyle: .alert)
            let actionOkey = UIAlertAction(title: AlertConnection.buttonReload, style: .default) { action in
                self.getData()
            }
            let actionCancel = UIAlertAction(title: AlertConnection.buttonCancel, style: .cancel, handler: nil)
            alert.addAction(actionOkey)
            alert.addAction(actionCancel)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return openMoviesList.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Properties.cellName, for: indexPath) as? MainCollectionViewCell {
            var state = false
            for item in savedMovieIds where item == openMoviesList[indexPath.item].id {
                state = true
            }
            cell.setupCell(movie: openMoviesList[indexPath.item], isSaved: state, delegate: self)
            return cell
        }
        fatalError()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.present(DetailsViewController(movie: openMoviesList[indexPath.row]), animated: true, completion: nil)
    }
}

extension MainViewController: MainCollectionViewCellDelegate {
    func markMovie(movie: Movie) -> Bool {
        return buttonAdd(movie: movie)
    }
    
    func buttonAdd(movie: Movie) -> Bool {
        if CoreDataManager.data.receiveItem(movie.id) == nil {
            CoreDataManager.data.saveItem(movie: movie)
            savedMovieIds.append(movie.id)
            return true
        } else {
            CoreDataManager.data.deleteItem(id: movie.id)
            if let index = savedMovieIds.firstIndex(of: movie.id) {
                savedMovieIds.remove(at: index)
            }
            return false
        }
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            openMoviesList = moviesList
            mainCollection?.reloadData()
            return
        }
        filterForSearchResults(text)
        mainCollection?.reloadData()
        
        func filterForSearchResults(_ text: String) {
                openMoviesList = moviesList.filter({ (movie: Movie) in
                    return movie.name?.lowercased().contains(text.lowercased()) ?? false
                })
        }
    }
}

