import UIKit

class FavoritesViewController: UIViewController {
    private var viewModel: FavoritesViewModelType!
    private var movieCollection: CollectionType?
    private var viewForMovieCollection = UIView()
    private let headView = UIView()
    private let searchController = UISearchController(searchResultsController: nil)
    private struct Properties {
        static let headViewBackgroundColor = UIColor.systemGray6.withAlphaComponent(0.2)
        static let headViewBorderWidth: CGFloat = 0.5
        static let headViewBorderColor = UIColor.systemGray4.cgColor
        static let searchBarTintColor = UIColor.lightGray
    }
    
    private struct AlertText {
        static let title = "Delete this movie?"
        static let buttonYes = "yes"
        static let buttonNo = "no"
    }
    
    convenience init(viewModel: FavoritesViewModel) {
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
        viewModel.updateAllData(fromNetwork: false)
        bindingProcessing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.updateAllData(fromNetwork: false)
        self.movieCollection?.updateCollection()
    }
    
    private func bindingProcessing() {
        viewModel.updateCollection.bind { [unowned self] _ in
            self.movieCollection?.updateCollection()
        }
        
        viewModel.alert.bind { [unowned self] _ in
            self.showAlert()
        }
        
        viewModel.indexPathItemToDelete.bind { [unowned self] index in
            movieCollection?.deleteItem(indexPath: index)
        }
        
        viewModel.movieForDetailsScreen.bind { [unowned self] movie in
            self.present(DetailsViewController(viewModel: DetailsViewModel(movie: movie)), animated: true, completion: nil)
        }
    }
    
    private func customizeViews() {
        setHeadView()
        setViewForMovieCollection()
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
        movieCollection = MainCollectionView(frame: viewForMovieCollection.safeAreaLayoutGuide.layoutFrame, viewModel: viewModel, activateRefreshControl: false)
        if let movieCollection = movieCollection {
            viewForMovieCollection.addSubview(movieCollection)
        }
    }
    
    private func setSearchController() {
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = Properties.searchBarTintColor
        headView.addSubview(searchController.searchBar)
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: AlertText.title, message: nil, preferredStyle: .alert)
        let actionOkey = UIAlertAction(title: AlertText.buttonYes, style: .default) { _ in
            self.viewModel.deleteItem()
            }
        let actionCancel = UIAlertAction(title: AlertText.buttonNo, style: .default) { _ in
        }
        alert.view.tintColor = .black
        alert.addAction(actionOkey)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
}

extension FavoritesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchTextUpdated(text: searchController.searchBar.text)
    }
}
