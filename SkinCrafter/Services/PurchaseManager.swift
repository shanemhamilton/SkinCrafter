import SwiftUI
import StoreKit

class PurchaseManager: NSObject, ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var isLoadingProducts = false
    @Published var isPremium = false
    @Published var hasProTools = false
    @Published var hasPremiumTemplates = false
    @Published var hasUnlimitedPalettes = false
    
    // Product IDs matching App Store Connect
    private let productIDs = [
        "com.inertu.MySkinCraft.removeads",
        "com.inertu.MySkinCraft.protools",
        "com.inertu.MySkinCraft.premiumtemplates",
        "com.inertu.MySkinCraft.unlimitedpalettes"
    ]
    
    var hasRemovedAds: Bool {
        purchasedProductIDs.contains("com.inertu.MySkinCraft.removeads")
    }
    
    override init() {
        super.init()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
        
        startObservingTransactions()
    }
    
    @MainActor
    func loadProducts() async {
        isLoadingProducts = true
        
        do {
            products = try await Product.products(for: productIDs)
            isLoadingProducts = false
        } catch {
            print("Failed to load products: \(error)")
            isLoadingProducts = false
        }
    }
    
    @MainActor
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    @MainActor
    func updatePurchasedProducts() async {
        var purchased = Set<String>()
        
        for await result in StoreKit.Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            purchased.insert(transaction.productID)
        }
        
        purchasedProductIDs = purchased
        
        // Update feature flags
        isPremium = hasRemovedAds
        hasProTools = purchasedProductIDs.contains("com.inertu.MySkinCraft.protools")
        hasPremiumTemplates = purchasedProductIDs.contains("com.inertu.MySkinCraft.premiumtemplates")
        hasUnlimitedPalettes = purchasedProductIDs.contains("com.inertu.MySkinCraft.unlimitedpalettes")
    }
    
    private func startObservingTransactions() {
        Task {
            for await result in StoreKit.Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await updatePurchasedProducts()
                await transaction.finish()
            }
        }
    }
    
    @MainActor
    func restore() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }
}

enum StoreError: Error {
    case failedVerification
}

// MARK: - Purchase UI
struct PurchaseView: View {
    @StateObject private var purchaseManager = PurchaseManager()
    @Environment(\.dismiss) private var dismiss
    @State private var purchaseError: String?
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        
                        Text("Unlock Premium Features")
                            .font(.title)
                            .bold()
                        
                        Text("Support development & get awesome features!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    if purchaseManager.isLoadingProducts {
                        ProgressView()
                            .padding()
                    } else {
                        // Products
                        ForEach(purchaseManager.products) { product in
                            PurchaseRow(
                                product: product,
                                isPurchased: purchaseManager.purchasedProductIDs.contains(product.id)
                            ) {
                                Task {
                                    do {
                                        _ = try await purchaseManager.purchase(product)
                                    } catch {
                                        purchaseError = error.localizedDescription
                                        showingError = true
                                    }
                                }
                            }
                        }
                    }
                    
                    // Features List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Premium Features Include:")
                            .font(.headline)
                        
                        FeatureRow(icon: "star.fill", text: "Remove all ads", unlocked: purchaseManager.hasRemovedAds)
                        FeatureRow(icon: "paintbrush.fill", text: "Pro drawing tools", unlocked: purchaseManager.hasProTools)
                        FeatureRow(icon: "square.stack.3d.up.fill", text: "Premium templates", unlocked: purchaseManager.hasPremiumTemplates)
                        FeatureRow(icon: "paintpalette.fill", text: "Unlimited palettes", unlocked: purchaseManager.hasUnlimitedPalettes)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Restore Button
                    Button(action: {
                        Task {
                            await purchaseManager.restore()
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Purchase Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(purchaseError ?? "Unknown error")
            }
        }
    }
}

struct PurchaseRow: View {
    let product: Product
    let isPurchased: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(.headline)
                
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isPurchased {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else {
                Button(action: action) {
                    Text(product.displayPrice)
                        .bold()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let unlocked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(unlocked ? .green : .gray)
                .frame(width: 24)
            
            Text(text)
                .foregroundColor(unlocked ? .primary : .secondary)
            
            Spacer()
            
            if unlocked {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            }
        }
    }
}