import RxSwift
import RxCocoa
import RxDataSources

typealias CurrencyCellModel = SectionModel<String, Currency>

class CurrenciesViewModel {
    
    public var sceneCoordinator: SceneCoordinatorProtocol
    
    private var transaction: Transaction?
    private var account: Account?
    
    public var tableItems: Observable<[CurrencyCellModel]>
    
    init(sceneCoordinator: SceneCoordinatorProtocol, transaction: Transaction) {
        self.sceneCoordinator = sceneCoordinator
        
        self.transaction = transaction
        
        tableItems = Observable.create {
            $0.onNext([CurrencyCellModel(model: "Currencies",
                                         items: Currency.allCases)])
            return Disposables.create { }
        }
    }
    
    init(sceneCoordinator: SceneCoordinatorProtocol, account: Account) {
        self.sceneCoordinator = sceneCoordinator
        
        self.account = account
        
        tableItems = Observable.create {
            $0.onNext([CurrencyCellModel(model: "Currencies",
                                         items: Currency.allCases)])
            return Disposables.create { }
        }
    }
    
    func changeCurrency(to currency: Currency) {
        transaction?.currency = currency.rawValue
        account?.currency = currency.rawValue
    }
    
}
