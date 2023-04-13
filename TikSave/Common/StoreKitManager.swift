//
//  StoreKitManager.swift
//  TikSave
//
//  Created by Christina Santana on 15/3/23.
//

import Foundation
import StoreKit

enum SubscriptionType: String, CaseIterable, Codable {
    case weekly, monthly, yearly
    
    var components: DateComponents {
        switch self {
        case .yearly:
            var dateComp = DateComponents()
            dateComp.year = 1
            return dateComp
        case .monthly:
            var dateComp = DateComponents()
            dateComp.month = 1
            return dateComp
        case .weekly:
            var dateComp = DateComponents()
            dateComp.weekday = 7
            return dateComp
        }
    }
    
    var identifier: String {
        switch self {
        case .yearly:
            return "com.tiksave.yearlysubscription"//Change
        case .monthly:
            return "com.tiksave.monthlysubsciption"
        case .weekly:
            return "com.tiksave.weeklysubscription"
        }
    }
    
    init?(identifier: String) {
        if identifier == SubscriptionType.yearly.identifier {
            self = .yearly
        } else if identifier == SubscriptionType.monthly.identifier {
            self = .monthly
        } else if identifier == SubscriptionType.weekly.identifier {
            self = .weekly
        }else {
            return nil
        }
    }
}


@available(iOS 15.0, *)
@MainActor
class StoreKitManager: NSObject {
    static var shared = StoreKitManager()
    
    var onFinish: () -> Void = {}
    
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs = Set<String>()
    
    //private let entitlementManager: EntitlementManager
    private var productsLoaded = false
    private var updates: Task<Void, Never>? = nil
    
    override init() {
        //self.entitlementManager = entitlementManager
        super.init()
        self.updates = observeTransactionUpdates()
        SKPaymentQueue.default().add(self)
    }
    
    func loadManager() {
        Task {
            try? await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        self.updates?.cancel()
    }
    
    func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: Set(SubscriptionType.allCases.map{ $0.identifier }))
        self.productsLoaded = true
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case let .success(.verified(transaction)):
            // Successful purchase
            await transaction.finish()
            await self.updatePurchasedProducts()
//            SharedService.shared.startDate = transaction.originalPurchaseDate
//            SharedService.shared.expirationDate = transaction.expirationDate
            onFinish()
        case let .success(.unverified(_, error)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            // ^^^
            break
        @unknown default:
            break
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            SharedService.shared.startDate = transaction.originalPurchaseDate
            SharedService.shared.expirationDate = transaction.expirationDate
            
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
        
        SharedService.shared.isPremium = !self.purchasedProductIDs.isEmpty
    }
    
    func restorePurchase() {
        _ = Task<Void, Never> {
            do {
                try await AppStore.sync()
            } catch {
                print(error)
            }
        }
    }
    
//    func setExpirationDate(id: String) {
//        if let productID = SubscriptionType(identifier: product?.productIdentifier ?? "") {
//            let currentDate = transaction.transactionDate ?? Date()
//            let futureDate = Calendar.current.date(byAdding: productID.components, to: currentDate)
//            PremiumService.shared.expirationDate = futureDate
//        }
//
////        if let type = SubscriptionType(identifier: id) {
////            Date().ad
////        }
//    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await verificationResult in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.updatePurchasedProducts()
            }
        }
    }
}

@available(iOS 15.0, *)
extension StoreKitManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}
