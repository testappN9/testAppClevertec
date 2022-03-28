import UIKit

class DetailsViewController: UIViewController {
    private var viewModel: DetailsViewModelType!
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let posterView = UIImageView()
    private let ratingLabel = UILabel()
    private let genresLabel = UILabel()
    private let descriptionLabel = UILabel()
    private struct Properties {
        static let screenBackgroundColor = UIColor.white
        static let insets: CGFloat = 10
        static let textColor = UIColor.darkGray
        static let posterAspectRatio: CGFloat = 1.5
        static let posterCornerRadius: CGFloat = 10
        static let genresFont = UIFont(name: "Optima Bold", size: 14)
        static let ratingBackgroundColor = UIColor.systemGray6.withAlphaComponent(0.9)
        static let ratingFont = UIFont(name: "Optima Bold", size: 17)
        static let ratingSize: CGFloat = 40
        static let descriptionFont = UIFont(name: "Optima Bold", size: 17)
    }
    
    convenience init(viewModel: DetailsViewModelType) {
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
        bindingProcessing()
        viewModel.viewsDidLoad()
        customizeViews()
    }
    
    private func bindingProcessing() {
        viewModel.image.bind { [unowned self] image in
            self.posterView.image = UIImage(data: image as Data)
        }
        viewModel.rating.bind { [unowned self] rating in
            self.ratingLabel.text = rating
        }
        viewModel.genres.bind { [unowned self] genres in
            self.genresLabel.text = genres
        }
        viewModel.descriptionReleased.bind { [unowned self] descriptionReleased in
            self.descriptionLabel.text = descriptionReleased
        }
    }
    
    private func customizeViews() {
        self.view.backgroundColor = Properties.screenBackgroundColor
        scrollViewDesign()
        posterViewDesign()
        ratingLabelDesign()
        genresLabelDesign()
        descriptionLabelDesign()
    }
    
    private func scrollViewDesign() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(view)
            make.top.equalTo(view).inset(Properties.insets)
        }
        contentView.snp.makeConstraints { make in
            make.centerX.equalTo(scrollView)
            make.width.equalTo(scrollView)
            make.top.bottom.equalTo(scrollView)
        }
    }
    
    private func posterViewDesign() {
        let width = view.frame.width - (Properties.insets * 2)
        let height = width * Properties.posterAspectRatio
        posterView.contentMode = .scaleAspectFill
        posterView.layer.masksToBounds = true
        posterView.layer.cornerRadius = Properties.posterCornerRadius
        contentView.addSubview(posterView)
        posterView.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.leading.equalTo(contentView).inset(Properties.insets)
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
    }
    
    private func ratingLabelDesign() {
        ratingLabel.backgroundColor = Properties.ratingBackgroundColor
        ratingLabel.textColor = Properties.textColor
        ratingLabel.font = Properties.ratingFont
        ratingLabel.textAlignment = .center
        ratingLabel.layer.masksToBounds = true
        ratingLabel.layer.cornerRadius = Properties.ratingSize / 2
        posterView.addSubview(ratingLabel)
        ratingLabel.snp.makeConstraints { make in
            make.top.trailing.equalTo(posterView).inset(Properties.insets)
            make.width.height.equalTo(Properties.ratingSize)
        }
    }
    
    private func genresLabelDesign() {
        genresLabel.textColor = Properties.textColor
        genresLabel.font = Properties.genresFont
        genresLabel.textAlignment = .center
        contentView.addSubview(genresLabel)
        genresLabel.snp.makeConstraints { make in
            make.top.equalTo(posterView.snp.bottom)
            make.trailing.leading.equalTo(contentView).inset(Properties.insets)
        }
    }
    
    private func descriptionLabelDesign() {
        descriptionLabel.textAlignment = .justified
        descriptionLabel.font = Properties.descriptionFont
        descriptionLabel.textColor = Properties.textColor
        
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(genresLabel.snp.bottom).offset(Properties.insets)
            make.leading.trailing.bottom.equalTo(contentView).inset(Properties.insets)
        }
    }
}
