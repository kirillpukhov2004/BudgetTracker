import UIKit
import RxSwift
import RxCocoa

class TextFieldAccountTableViewCell: UITableViewCell {
    static let identifier = "TextFieldAccountTableViewCellIdentifier"
    
    private var disposeBag: DisposeBag!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textField: UITextField!
    
    func configure(title: String, account: Account) {
        disposeBag = DisposeBag()
        
        titleLabel.text = title
        
        textField.text = account.title
        
        textField.rx.text.orEmpty
            .skip(until: textField.rx.controlEvent(.editingDidBegin))
            .take(until: textField.rx.controlEvent(.editingDidEnd))
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
            .bind(to: account.rx.title)
            .disposed(by: disposeBag)
    }

}
