import UIKit

class MainViewController: UIViewController {
    private var viewModel: MainViewModelType!
    private var movieCollection: CollectionType?
    private var viewForMovieCollection = UIView()
    private var animatedСircle = LoadingView()
    private let headView = UIView()
    private let searchController = UISearchController(searchResultsController: nil)
    private struct Properties {
        static let loadCircleSize: CGFloat = 100
        static let loadCircleBackgroundColor = UIColor.clear
        static let headViewBackgroundColor = UIColor.systemGray6.withAlphaComponent(0.2)
        static let headViewBorderWidth: CGFloat = 0.5
        static let headViewBorderColor = UIColor.systemGray4.cgColor
        static let searchBarTintColor = UIColor.lightGray
    }
    
    private struct AlertText {
        static let title = "Something went wrong"
        static let buttonReload = "try again"
        static let buttonCancel = "cancel"
    }
    
    convenience init(viewModel: MainViewModelType) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
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
        viewModel.updateAllData(fromNetwork: true)
        bindingProcessing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.updateAllData(fromNetwork: false)
        self.movieCollection?.updateCollection()
    }
    
    private func bindingProcessing() {
        viewModel.updateCollection.bind { [unowned self] _ in
            self.movieCollection?.endRefreshing()
            self.movieCollection?.updateCollection()
            self.animatedСircle.isHidden = true
            self.animatedСircle.animationStop()
        }
        
        viewModel.alert.bind { [unowned self] error in
            self.showAlert(error: error)
            self.animatedСircle.isHidden = true
            self.animatedСircle.animationStop()
        }
        
        viewModel.movieForDetailsScreen.bind { [unowned self] movie in
            self.present(DetailsViewController(viewModel: DetailsViewModel(movie: movie)), animated: true, completion: nil)
        }
    }
    
    private func customizeViews() {
        setHeadView()
        setViewForMovieCollection()
        setAnimatedСircle()
        setSearchController()
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

    private func setViewForMovieCollection() {
        view.addSubview(viewForMovieCollection)
        viewForMovieCollection.snp.makeConstraints { make in
            make.top.equalTo(headView.snp.bottom)
            make.height.equalTo((tabBarController?.tabBar.frame.minY ?? view.safeAreaLayoutGuide.layoutFrame.height) - headView.safeAreaLayoutGuide.layoutFrame.height)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        movieCollection = MainCollectionView(frame: viewForMovieCollection.safeAreaLayoutGuide.layoutFrame, viewModel: viewModel, activateRefreshControl: true)
        if let movieCollection = movieCollection {
            viewForMovieCollection.addSubview(movieCollection)
        }
    }
    
    private func setAnimatedСircle() {
        animatedСircle.backgroundColor = Properties.loadCircleBackgroundColor
        viewForMovieCollection.addSubview(animatedСircle)
        animatedСircle.snp.makeConstraints { make in
            make.width.height.equalTo(Properties.loadCircleSize)
            make.centerX.centerY.equalTo(viewForMovieCollection)
        }
    }
    
    private func setSearchController() {
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = Properties.searchBarTintColor
        headView.addSubview(searchController.searchBar)
    }
    
    private func showAlert(error: NetworkError) {
        let alert = UIAlertController(title: AlertText.title, message: error.rawValue, preferredStyle: .alert)
        let actionOkey = UIAlertAction(title: AlertText.buttonReload, style: .default) { _ in
            self.viewModel.updateAllData(fromNetwork: true)        }
        let actionCancel = UIAlertAction(title: AlertText.buttonCancel, style: .default) { _ in
        }
        alert.view.tintColor = .black
        alert.addAction(actionOkey)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchTextUpdated(text: searchController.searchBar.text)
    }
}
