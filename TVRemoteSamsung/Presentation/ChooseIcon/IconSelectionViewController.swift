import UIKit
import SnapKit
import CustomBlurEffectView
import Utilities

// MARK: - Models

enum AppIcon: String, CaseIterable, Identifiable {
    case primary = "AppIcon"
    case alternative = "AppIcon-1"
    
    var previewImage: UIImage? {
        switch self {
        case .primary: return UIImage(named: "playstore")
        case .alternative: return UIImage(named: "playstore-1")
        }
    }
    
    var id: String { rawValue }
}

// MARK: - View Controller

final class IconSelectionViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var backgroundBlurView = CustomBlurEffectView().then {
        $0.blurRadius = 3
        $0.colorTint = UIColor(hex: "171313")
        $0.colorTintAlpha = 0.3
    }
    
    private lazy var contentContainer = UIView().then {
        $0.backgroundColor = UIColor(hex: "31337C")
        $0.layer.cornerRadius = 30
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.text = "Choose icon".localized
        $0.font = .font(weight: .medium, size: 20)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var closeButton = UIButton().then {
        $0.setImage(UIImage(named: "close"), for: .normal)
        $0.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }
    
    private lazy var iconsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 25
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(IconSelectionCell.self, forCellWithReuseIdentifier: IconSelectionCell.reuseIdentifier)
        return collectionView
    }()
    
    // MARK: - Properties
    
    private let availableIcons = AppIcon.allCases
    private var selectedIconIndexPath: IndexPath?
    private let cellSize = CGSize(width: 150, height: 150)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureLayoutConstraints()
        setupInitialSelection()
    }
    
    // MARK: - Private Methods
    
    private func configureViewHierarchy() {
        view.addSubview(backgroundBlurView)
        backgroundBlurView.addSubview(contentContainer)
        
        contentContainer.addSubviews(
            titleLabel,
            closeButton,
            iconsCollectionView
        )
    }
    
    private func configureLayoutConstraints() {
        backgroundBlurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        contentContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(297)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.leading.trailing.equalToSuperview().inset(22)
        }
        
        closeButton.snp.makeConstraints {
            $0.size.equalTo(33)
            $0.top.equalToSuperview().inset(27)
            $0.trailing.equalToSuperview().inset(24)
        }
        
        let horizontalInset = (UIScreen.main.bounds.width - 325) / 2
        
        iconsCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(horizontalInset)
            $0.bottom.equalToSuperview().inset(54)
            $0.height.equalTo(cellSize.height)
        }
    }
    
    private func setupInitialSelection() {
        let currentIconName = UIApplication.shared.alternateIconName
        if let selectedIndex = availableIcons.firstIndex(where: { $0.rawValue == currentIconName }) {
            selectedIconIndexPath = IndexPath(item: selectedIndex, section: 0)
        } else {
            selectedIconIndexPath = IndexPath(item: 0, section: 0)
        }
        
        iconsCollectionView.reloadData()
    }
    
    private func updateAppIcon(to icon: AppIcon) {
        let iconName: String? = (icon != .primary) ? icon.rawValue : nil
        
        guard UIApplication.shared.alternateIconName != iconName else { return }
        
        UIApplication.shared.setAlternateIconName(iconName) { [weak self] error in
            if let error = error {
                self?.handleIconChangeError(error)
            }
        }
    }
    
    private func handleIconChangeError(_ error: Error) {
        print("Failed to update app icon: \(error.localizedDescription)")
    }
    
    private func generateSelectionFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Actions
    
    @objc private func didTapCloseButton() {
        generateSelectionFeedback()
        dismiss(animated: true)
    }
}

// MARK: - CollectionView Delegate & DataSource

extension IconSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableIcons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: IconSelectionCell.reuseIdentifier,
            for: indexPath
        ) as! IconSelectionCell
        
        let icon = availableIcons[indexPath.item]
        let isSelected = selectedIconIndexPath == indexPath
        cell.configure(with: icon.previewImage, isSelected: isSelected)
        
        return cell
    }
}

extension IconSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedIconIndexPath != indexPath else { return }
        
        generateSelectionFeedback()
        
        let previousSelection = selectedIconIndexPath
        selectedIconIndexPath = indexPath
        
        updateAppIcon(to: availableIcons[indexPath.item])
        
        var indexPathsToUpdate = [indexPath]
        if let previous = previousSelection {
            indexPathsToUpdate.append(previous)
        }
        
        collectionView.performBatchUpdates {
            collectionView.reloadItems(at: indexPathsToUpdate)
        }
    }
}

extension IconSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}

// MARK: - CollectionView Cell

final class IconSelectionCell: UICollectionViewCell {
    static let reuseIdentifier = "IconSelectionCell"
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCellAppearance()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCellAppearance() {
        contentView.layer.cornerRadius = 24
        contentView.backgroundColor = .clear
    }
    
    private func setupLayout() {
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    func configure(with iconImage: UIImage?, isSelected: Bool) {
        iconImageView.image = iconImage
        
        if isSelected {
            contentView.applyGradientBorder(
                colors: [UIColor(hex: "0226EC"), UIColor(hex: "20D2FF")],
                lineWidth: 8,
                cornerRadius: 24
            )
        } else {
            contentView.layer.borderColor = UIColor.clear.cgColor
            contentView.layer.borderWidth = 1
            contentView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        }
    }
}
