import '../../../billing/data/models/product_model.dart';
import '../../../billing/data/repositories/billing_repository.dart';

class ProductsRepository {
  ProductsRepository({BillingRepository? billingRepository})
    : _billingRepository = billingRepository ?? BillingRepository();

  final BillingRepository _billingRepository;

  Future<List<ProductModel>> getAll() => _billingRepository.getProducts();
}
