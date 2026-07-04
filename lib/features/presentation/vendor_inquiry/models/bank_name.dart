/// Bank options for the vendor company details form (single-select dropdown).
/// NOTE: Placeholder list of common Indian banks — replace with the backend
/// master list when available.
enum BankName {
  sbi('State Bank of India'),
  hdfc('HDFC Bank'),
  icici('ICICI Bank'),
  axis('Axis Bank'),
  pnb('Punjab National Bank'),
  bob('Bank of Baroda'),
  kotak('Kotak Mahindra Bank'),
  canara('Canara Bank'),
  unionBank('Union Bank of India'),
  idbi('IDBI Bank'),
  yesBank('Yes Bank'),
  indusind('IndusInd Bank');

  const BankName(this.label);
  final String label;
}
