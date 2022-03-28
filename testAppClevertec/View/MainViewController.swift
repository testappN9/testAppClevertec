import UIKit

class MainViewController: UIViewController {
    private var viewModel: MainFavoritesViewModelType!
    private var dataArrayForCollection = [(Movie, Bool)]()
    private var stateForCell = true
    private let mainCollection = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewLayout())
    private var refreshControl: UIRefreshControl?
    private var animatedСircle: LoadingView?
    private let headView = UIView()
    private let searchController = UISearchController(searchResultsController: nil)
    private struct Properties {
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
    
    private struct AlertText {
        static let connectTitle = "Something went wrong"
        static let connectButtonReload = "try again"
        static let connectButtonCancel = "cancel"
        static let deleteTitle = "Delete this movie?"
        static let deleteButtonYes = "yes"
        static let deleteButtonNo = "no"
    }
    
    convenience init(viewModel: MainFavoritesViewModelType, refreshControl: UIRefreshControl?, animatedСircle: LoadingView?) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.refreshControl = refreshControl
        self.animatedСircle = animatedСircle
    }
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViews()
        viewModel.allDataWillUpdate()
        bindingProcessing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.savedDataWillUpdate()
        self.mainCollection.reloadData()
    }
    
    private func bindingProcessing() {
        viewModel.readyMoviesList.bind { [unowned self] array in
            self.dataArrayForCollection = array
            self.refreshControl?.endRefreshing()
            self.animatedСircle?.isHidden = true
            self.animatedСircle?.animationStop()
            self.mainCollection.reloadData()
        }
        
        viewModel.alert.bind { [unowned self] type in
            self.showAlert(type: type)
        }
        
        viewModel.stateForCell.bind { [unowned self] state in
            self.stateForCell = state
        }
    }
    
    private func customizeViews() {
        setHeadView()
        setMainCollection()
        setAnimatedСircle()
        setRefreshControl()
        setSearchController()
    }
    
    private func setAnimatedСircle() {
        guard let circle = animatedСircle else { return }
        circle.backgroundColor = Properties.loadCircleBackgroundColor
        mainCollection.addSubview(circle)
        circle.snp.makeConstraints { make in
            make.width.height.equalTo(Properties.loadCircleSize)
            make.centerX.centerY.equalTo(mainCollection)
        }
    }
    
    private func setHeadView() {
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
    
    private func setRefreshControl() {
        refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        viewModel.allDataWillUpdate()
    }
    
    private func setSearchController() {
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = Properties.searchBarTintColor
        headView.addSubview(searchController.searchBar)
    }
    
    private func setMainCollection() {
        let mainCollectionLayout = UICollectionViewFlowLayout()
        mainCollectionLayout.sectionInset.top = Properties.mainCollectionTopBottomInset
        mainCollectionLayout.sectionInset.bottom = Properties.mainCollectionTopBottomInset
        let itemWidth = self.view.frame.width - Properties.mainCollectionItemSideInsets
        let itemHeight = itemWidth * Properties.mainCollectionItemAspectRatio
        mainCollectionLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        mainCollection.frame = self.view.bounds
        mainCollection.collectionViewLayout = mainCollectionLayout
        mainCollection.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: Properties.cellName)
        mainCollection.delegate = self
        mainCollection.dataSource = self
        mainCollection.refreshControl = refreshControl
        mainCollection.backgroundColor = Properties.mainCollectionBackgroundColor
        view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { make in
            make.top.equalTo(headView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func showAlert(type: AlertType) {
        var title = AlertText.deleteTitle
        var okay = AlertText.deleteButtonYes
        var cancel = AlertText.deleteButtonNo
        if type == .noConnection {
            title = AlertText.connectTitle
            okay = AlertText.connectButtonReload
            cancel = AlertText.connectButtonCancel
        }
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let actionOkey = UIAlertAction(title: okay, style: .default) { _ in
            self.viewModel.movieMarked(movie: nil)
            self.viewModel.allDataWillUpdate()
        }
        let actionCancel = UIAlertAction(title: cancel, style: .default) { _ in
        }
        alert.view.tintColor = .black
        alert.addAction(actionOkey)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArrayForCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Properties.cellName, for: indexPath) as? MainCollectionViewCell {
            cell.setupCell(movie: dataArrayForCollection[indexPath.item], delegate: self)
            return cell
        }
        fatalError()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.present(DetailsViewController(viewModel: DetailsScreenViewModel(movie: dataArrayForCollection[indexPath.row].0)), animated: true, completion: nil)
    }
}

extension MainViewController: MainCollectionViewCellType {
    func markMovie(movie: Movie) -> Bool {
        viewModel.movieMarked(movie: movie)
        return stateForCell
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchTextUpdated(text: searchController.searchBar.text)
    }
}
