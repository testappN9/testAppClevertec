import UIKit
import SnapKit

class MainCollectionViewCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let heartButton = UIButton()
    private let titleLabel = UILabel()
    private let yearGenreLabel = UILabel()
    private var heartState = false
    private var currentMovie: Movie?
    private weak var delegate: MainCollectionViewCellType?
    private struct Properties {
        static let inset = 10
        static let cornerRadius: CGFloat = 10
        static let shadowOffset = 3
        static let shadowOpacity: Float = 0.7
        static let titleTextColor = UIColor.black.withAlphaComponent(0.4)
        static let titleStrokeColor = UIColor.systemGray6
        static let titleStroke = -7
        static let titleFont = UIFont(name: "Gill Sans UltraBold", size: 20)
        static let yearGenreLabelBackgroundColor = UIColor.systemGray6.withAlphaComponent(0.9)
        static let yearGenreLabelTextColor = UIColor.darkGray
        static let yearGenreLabelFont = UIFont(name: "Optima Bold", size: 14)
        static let yearGenreHeartHeight: CGFloat = 25
        static let heartButtonSize: CGFloat = 25
        static let heartButtonColor = UIColor.systemGray6
        static let heartButtonSelectedText = "\u{2665}"
        static let heartButtonUnselectedText = "\u{2661}"
        static let imageViewColor = UIColor.systemGray4
    }
    private struct DateFormatConstants {
        static let before = "yyyy-MM-dd"
        static let after = "yyyy"
        static let incorrectData = ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        cellDesign()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func cellDesign() {
        addShadowsToContentView()
        imageViewDesign()
        titleLabelDesign()
        yearGenreLabelDesign()
        heartButtonDesign()
    }
    
    private func addShadowsToContentView() {
        contentView.layer.cornerRadius = Properties.cornerRadius
        contentView.layer.shadowOffset = CGSize(width: Properties.shadowOffset, height: Properties.shadowOffset)
        contentView.layer.shadowOpacity = Properties.shadowOpacity
    }
    
    private func imageViewDesign() {
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.layer.shadowOffset = CGSize(width: Properties.shadowOffset, height: Properties.shadowOffset)
        imageView.layer.shadowOpacity = Properties.shadowOpacity
        imageView.backgroundColor = Properties.imageViewColor
        imageView.layer.cornerRadius = Properties.cornerRadius
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    
    private func titleLabelDesign() {
        imageView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(contentView).inset(Properties.inset)
        }
    }
    
    private func yearGenreLabelDesign() {
        yearGenreLabel.backgroundColor = Properties.yearGenreLabelBackgroundColor
        yearGenreLabel.layer.masksToBounds = true
        yearGenreLabel.layer.cornerRadius = Properties.cornerRadius / 2
        yearGenreLabel.font = Properties.yearGenreLabelFont
        yearGenreLabel.textColor = Properties.yearGenreLabelTextColor
        imageView.addSubview(yearGenreLabel)
        yearGenreLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView).inset(Properties.inset)
            make.height.equalTo(Properties.yearGenreHeartHeight)
        }
    }
    
    private func heartButtonDesign() {
        heartButtonText()
        heartButton.titleLabel?.font = UIFont.systemFont(ofSize: Properties.heartButtonSize)
        heartButton.setTitleColor(Properties.heartButtonColor, for: .normal)
        heartButton.isUserInteractionEnabled = true
        heartButton.addTarget(self, action: #selector(heartButtonAction(sender:)), for: .touchUpInside)
        imageView.addSubview(heartButton)
        heartButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(imageView).inset(Properties.inset)
            make.height.width.equalTo(Properties.yearGenreHeartHeight)
        }
    }
    
    @objc private func heartButtonAction(sender: UIButton) {
        guard let movie = currentMovie, let controller = delegate else { return }
        heartState = controller.markMovie(movie: movie)
        heartButtonText()
    }
    
    private func heartButtonText() {
        heartButton.setTitle(heartState ? Properties.heartButtonSelectedText : Properties.heartButtonUnselectedText, for: .normal)
    }
    
    func setupCell(movie: (Movie, Bool), delegate: MainCollectionViewCellType?) {
        self.delegate = delegate
        currentMovie = movie.0
        heartState = movie.1
        heartButtonText()
        titleLabel.attributedText = titleText(name: movie.0.name)
        yearGenreLabel.text = "\(movie.0.released ?? "")|\(movie.0.genresReady?.last ?? "")"
        guard let image = movie.0.backgroundImageReady else { return }
        imageView.image = UIImage(data: image as Data)
    }
    
    private func titleText(name: String?) -> NSAttributedString {
        guard let text = name else { return NSAttributedString()}
        let attrString = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.foregroundColor: Properties.titleTextColor,
            NSAttributedString.Key.strokeColor: Properties.titleStrokeColor,
            NSAttributedString.Key.strokeWidth: Properties.titleStroke,
            NSAttributedString.Key.font: Properties.titleFont as Any
            ]
        )
        return attrString
    }
}
