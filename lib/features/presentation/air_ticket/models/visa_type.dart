/// Visa type enum for air ticket booking
enum VisaType {
  visitorVisa('Visitor Visa'),
  studentVisa('Student Visa'),
  pr('PR'),
  workPermit('Work Permit');

  const VisaType(this.label);
  final String label;
}






