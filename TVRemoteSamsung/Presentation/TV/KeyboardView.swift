import UIKit
import SnapKit
import Utilities

final class KeyboardView: UIView {
    
    var onNumberTapped: ((Int) -> Void)?
    
    private lazy var oneButton: UIButton = {
        let view = UIButton()
        view.setTitle("1", for: .normal)
        view.titleLabel?.font = .font(weight: .regular, size: 24)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.tag = 1
        view.snp.makeConstraints { make in
            make.width.equalTo(72)
        }
        view.add(target: self, action: #selector(numberOneTapped))
        return view
    }()
    
    private lazy var twoButton: UIButton = {
        let view = UIButton()
        view.setTitle("2", for: .normal)
        view.tag = 2
        view.titleLabel?.font = .font(weight: .regular, size: 24)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.snp.makeConstraints { make in
            make.width.equalTo(72)
        }
        view.add(target: self, action: #selector(numberTwoTapped))
        return view
    }()
    
    private lazy var threeButton: UIButton = {
        let view = UIButton()
        view.setTitle("3", for: .normal)
        view.tag = 3
        view.titleLabel?.font = .font(weight: .regular, size: 24)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.snp.makeConstraints { make in
            make.width.equalTo(72)
        }
        view.add(target: self, action: #selector(numberThreeTapped))
        return view
    }()
    
    private lazy var topButtonsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [oneButton, twoButton, threeButton])
        view.axis = .horizontal
        view.spacing = 20.5
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var fourButton: UIButton = {
        let view = UIButton()
        view.setTitle("4", for: .normal)
        view.tag = 4
        view.titleLabel?.font = .font(weight: .regular, size: 24)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.snp.makeConstraints { make in
            make.width.equalTo(72)
        }
        view.add(target: self, action: #selector(numberFourTapped))
        return view
    }()
    
    private lazy var fiveButton: UIButton = {
        let view = UIButton()
        view.setTitle("5", for: .normal)
        view.tag = 5
        view.titleLabel?.font = .font(weight: .regular, size: 24)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.snp.makeConstraints { make in
            make.width.equalTo(72)
        }
        view.add(target: self, action: #selector(numberFiveTapped))
        return view
    }()
    
    private lazy var sixButton: UIButton = {
        let view = UIButton()
        view.setTitle("6", for: .normal)
        view.tag = 6
        view.titleLabel?.font = .font(weight: .regular, size: 24)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.snp.makeConstraints { make in
            make.width.equalTo(72)
        }
        view.add(target: self, action: #selector(numberSixTapped))
        return view
    }()
    
    private lazy var zeroButton: UIButton = {
        let view = UIButton()
        view.setTitle("0", for: .normal)
        view.tag = 0
        view.titleLabel?.font = .font(weight: .regular, size: 24)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.snp.makeConstraints { make in
            make.width.equalTo(72)
        }
        view.add(target: self, action: #selector(numberZeroTapped))
        return view
    }()
    
    private lazy var centerButtonsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [fourButton, fiveButton, sixButton])
        view.axis = .horizontal
        view.spacing = 20.5
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var sevenButton: UIButton = {
        let view = UIButton()
        view.setTitle("7", for: .normal)
        view.tag = 7
        view.titleLabel?.font = .font(weight: .regular, size: 24)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.snp.makeConstraints { make in
            make.width.equalTo(72)
        }
        view.add(target: self, action: #selector(numberSevenTapped))
        return view
    }()
    
    private lazy var eightButton: UIButton = {
        let view = UIButton()
        view.setTitle("8", for: .normal)
        view.tag = 8
        view.titleLabel?.font = .font(weight: .regular, size: 24)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.snp.makeConstraints { make in
            make.width.equalTo(72)
        }
        view.add(target: self, action: #selector(numberEightTapped))
        return view
    }()
    
    private lazy var nineButton: UIButton = {
        let view = UIButton()
        view.setTitle("9", for: .normal)
        view.tag = 9
        view.titleLabel?.font = .font(weight: .regular, size: 24)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        
        view.snp.makeConstraints { make in
            make.width.equalTo(72)
        }
        view.add(target: self, action: #selector(numberNineTapped))
        return view
    }()
    
    private lazy var bottomButtonsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [sevenButton, eightButton, nineButton])
        view.axis = .horizontal
        view.spacing = 20.5
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var zeroButtonsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [UIView(), zeroButton, UIView()])
        view.axis = .horizontal
        view.spacing = 20.5
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [topButtonsStackView, centerButtonsStackView, bottomButtonsStackView, zeroButtonsStackView])
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.alignment = .center
        view.spacing = 12
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.height != .zero {
            
            if bounds.height < ((72 * 4) + 36) {
                
                let height = (bounds.height - 100) / 4
                
                bottomButtonsStackView.snp.makeConstraints { make in
                    make.height.equalTo(height)
                }
                
                centerButtonsStackView.snp.makeConstraints { make in
                    make.height.equalTo(height)
                }
                
                topButtonsStackView.snp.makeConstraints { make in
                    make.height.equalTo(height)
                }
                
                zeroButtonsStackView.snp.makeConstraints { make in
                    make.height.equalTo(height)
                }
                
            } else {
                bottomButtonsStackView.snp.makeConstraints { make in
                    make.height.equalTo(72)
                }
                
                centerButtonsStackView.snp.makeConstraints { make in
                    make.height.equalTo(72)
                }
                
                topButtonsStackView.snp.makeConstraints { make in
                    make.height.equalTo(72)
                }
                
                zeroButtonsStackView.snp.makeConstraints { make in
                    make.height.equalTo(72)
                }
            }
        }
    }
    
    @objc private func numberZeroTapped() {
        onNumberTapped?(0)
    }
    
    @objc private func numberOneTapped() {
        onNumberTapped?(1)
    }
    
    @objc private func numberTwoTapped() {
        onNumberTapped?(2)
    }
    
    @objc private func numberThreeTapped() {
        onNumberTapped?(3)
    }
    
    @objc private func numberFourTapped() {
        onNumberTapped?(4)
    }
    
    @objc private func numberFiveTapped() {
        onNumberTapped?(5)
    }
    
    @objc private func numberSixTapped() {
        onNumberTapped?(6)
    }
    
    @objc private func numberSevenTapped() {
        onNumberTapped?(7)
    }
    
    @objc private func numberEightTapped() {
        onNumberTapped?(8)
    }
    
    @objc private func numberNineTapped() {
        onNumberTapped?(9)
    }
}
