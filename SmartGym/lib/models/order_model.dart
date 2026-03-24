class OrderModel {
  final int orderId;
  final String paymentUrl;
  final double total;
  final String status;
  final String? blockchainTxHash;

  OrderModel({
    required this.orderId,
    required this.paymentUrl,
    required this.total,
    required this.status,
    this.blockchainTxHash,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: (json['orderId'] ?? json['OrderId']) as int,
      paymentUrl: (json['paymentUrl'] ?? json['PaymentUrl']) as String,
      total: ((json['total'] ?? json['Total']) as num).toDouble(),
      status: (json['status'] ?? json['Status']) as String? ?? 'Pending',
      blockchainTxHash: (json['blockchainTxHash'] ?? json['BlockchainTxHash']) as String?,
    );
  }
}
