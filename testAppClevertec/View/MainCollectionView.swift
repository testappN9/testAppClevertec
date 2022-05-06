import UIKit

class MainCollectionView: UIView, CollectionType {
    private weak var delegate: CollectionDataSourceType!
    private let movieCollection = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewLayout())
    private var refreshControl: UIRefreshControl?
    private struct Properties {
        static let cellName = "ListOfGamesViewCell"
        static let collectionBackgroundColor = UIColor.clear
        static let collectionTopBottomInset: CGFloat = 10
        static let collectionItemSideInsets: CGFloat = 20
        static let collectionItemAspectRatio: CGFloat = 0.62
        static let searchBarTintColor = UIColor.lightGray
    }
    
    init(frame: CGRect, viewModel: CollectionDataSourceType, activateRefreshControl: Bool) {
        super.init(frame: frame)
        self.delegate = viewModel
        self.refreshControl = activateRefreshControl ? UIRefreshControl() : nil
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        setRefreshControl()
        setCollection()
    }
    
    private func setRefreshControl() {
        refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
    }

    @objc private func refresh(sender: UIRefreshControl) {
        delegate.updateAllData(fromNetwork: true)
    }
    
    private func setCollection() {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.sectionInset.top = Properties.collectionTopBottomInset
        collectionLayout.sectionInset.bottom = Properties.collectionTopBottomInset
        let itemWidth = self.frame.width - Properties.collectionItemSideInsets
        let itemHeight = itemWidth * Properties.collectionItemAspectRatio
        collectionLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        movieCollection.frame = self.bounds
        movieCollection.collectionViewLayout = collectionLayout
        movieCollection.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: Properties.cellName)
        movieCollection.delegate = self
        movieCollection.dataSource = self
        movieCollection.refreshControl = refreshControl
        movieCollection.backgroundColor = Properties.collectionBackgroundColor
        self.addSubview(movieCollection)
    }
    
    func updateCollection() {
        movieCollection.reloadData()
    }
    
    func endRefreshing() {
        movieCollection.refreshControl?.endRefreshing()
    }
    
    func deleteItem(indexPath: Int) {
        print("connect")
        movieCollection.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
    }
}

extension MainCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.getNumberOfCells()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Properties.cellName, for: indexPath) as? MainCollectionViewCell {
            cell.indexPath = indexPath.item
            cell.setupCell(movie: delegate.getMovieForIndexPath(indexPath: indexPath.item), delegate: delegate)
            return cell
        }
        fatalError()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.openDetailsScreen(indexPath: indexPath.item)
    }
}
