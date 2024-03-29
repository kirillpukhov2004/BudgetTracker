import RxSwift
import RxCocoa
import RxDataSources

typealias TransactionCellModel = SectionModel<String, TransactionTableViewCellType>

final class TransactionViewModel {
    
    public let sceneCoordinator: SceneCoordinatorProtocol
    public let managedObjectContextService: ManagedObjectContextServiceProtocol
    
    public let transaction: Transaction
    
    // Rx
    private let disposeBag: DisposeBag
    
    // Inputs
    private(set) var doneAction: PublishSubject<Void>!
    private(set) var cancelAction: PublishSubject<Void>!
    private(set) var chooseCurrencyAction: PublishSubject<Void>!
    
    // Outputs
    private(set) var isDoneButtonEnabled: Driver<Bool>!
    private(set) var tableItems: Observable<[TransactionCellModel]>!
    
    init(for transaction: Transaction, sceneCoordinator: SceneCoordinatorProtocol, managedObjectContextService: ManagedObjectContextServiceProtocol) {
        self.managedObjectContextService = managedObjectContextService
        
        self.sceneCoordinator = sceneCoordinator
        
        self.transaction = transaction
        if transaction.currency == nil {
            transaction.currency = transaction.account?.currency
        }
        
        disposeBag = DisposeBag()
        
        configureActions()
        configureProperties()
        configureTableItems()
    }
}

extension TransactionViewModel {
    
    func configureActions() {
        doneAction = PublishSubject<Void>()
        doneAction
            .subscribe(onNext: { [weak self] in
                do {
                    try self?.managedObjectContextService.saveContext()
                    self?.sceneCoordinator.pop(animated: true)
                } catch {
                    print("\(#file) \(#function) \(error.localizedDescription)")
                    self?.managedObjectContextService.rollbackContext()
                    self?.sceneCoordinator.pop(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        cancelAction = PublishSubject<Void>()
        cancelAction
            .subscribe(onNext: { [weak self] in
                self?.managedObjectContextService.rollbackContext()
                self?.sceneCoordinator.pop(animated: true)
            })
            .disposed(by: disposeBag)
        
        chooseCurrencyAction = PublishSubject<Void>()
        chooseCurrencyAction
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { fatalError() }
                
                let viewModel = CurrenciesViewModel(sceneCoordinator: strongSelf.sceneCoordinator,
                                                    transaction: strongSelf.transaction)
                viewModel.sceneCoordinator.transition(to: .currencies(viewModel), with: .push)
            })
            .disposed(by: disposeBag)
    }
    
    func configureProperties() {
        let transactionTitleObserver = transaction.rx.observe(\.title).asDriver(onErrorJustReturn: nil)
        let transactionAmountObserver = transaction.rx.observe(\.amount).asDriver(onErrorJustReturn: nil)
        
        isDoneButtonEnabled = Driver<Bool>.combineLatest(
            transactionTitleObserver,
            transactionAmountObserver
        ){ title, amount in
            if title == nil || title == "" || amount == nil {
                return false
            }
            return true
        }
    }
    
    func configureTableItems() {
        tableItems = Observable.create { observable in
            observable.onNext([TransactionCellModel(model: "Transactions",
                                                    items: TransactionTableViewCellType.allCases)])
            return Disposables.create()
        }
    }

}
