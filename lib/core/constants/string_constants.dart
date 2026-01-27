/// Centralized string constants for the entire application
/// All hardcoded text strings should be defined here and accessed via this class
class StringConstant {
  // ========== General ==========
  static const String emptyString = '';
  static const String asterisk = '*';
  static const String somethingWentWrong = 'Something went wrong!';
  static const String connectionTimeout = 'Connection timeout';
  static const String badResponse = 'Bad Response';
  static const String myCRM = 'My CRM';
  static const String webCRM = 'Web CRM';

  // ========== Navigation & Pages ==========
  static const String dashboard = 'Dashboard';
  static const String clientLeads = 'Client Leads';
  static const String inquiry = 'Inquiry';
  static const String inquiryManagement = 'Inquiry Management';
  static const String projectJobs = 'Project Jobs';
  static const String invoices = 'Invoices';
  static const String payments = 'Payments';
  static const String inventory = 'Inventory';
  static const String team = 'Team';
  static const String reminders = 'Reminders';
  static const String analysis = 'Analysis';
  static const String airTicket = 'Air Ticket';

  // ========== Company & Version ==========
  static const String zeemoDigital = 'ZEEMO DIGITAL';
  static const String emoDigital = 'EMO DIGITAL';
  static const String version = 'Version 1.0';

  // ========== Inquiry Form ==========
  static const String inquiryForm = 'Inquiry Form';
  static const String inquiryFormTitle = 'INQUIRY FORM';
  static const String fillInFormForCustomerInquiry = 'Fill in the form for customer inquiry';
  static const String fillFormForQuote = 'Provide flight booking information';
  static const String letsTalkAboutClients = "Let's talk about our Client's ";
  static const String project = 'project.';
  static const String inquiryFormDescription =
      'We are here to help you with your travel needs. Fill out the inquiry form below and our team will get back to you as soon as possible. We look forward to working with you on your next adventure.';
  static const String selectType = 'Select type';

  // ========== Inquiry Form Fields ==========
  static const String title = 'Title';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String phoneNumber = 'Phone Number';
  static const String email = 'E-mail';
  static const String address = 'Address';
  static const String referenceName = 'Reference Name';
  static const String referenceNumber = 'Reference Number';
  static const String typeOfBooking = 'Type of Booking';

  // ========== Inquiry Form Hints ==========
  static const String enterTitle = 'Enter title';
  static const String enterFirstName = 'Enter first name';
  static const String enterLastName = 'Enter last name';
  static const String enterPhoneNumber = 'Enter phone number';
  static const String enterEmail = 'Enter email';
  static const String enterAddress = 'Enter address';
  static const String enterReferenceName = 'Enter reference name';
  static const String enterReferenceNumber = 'Enter reference number';
  static const String selectRole = 'Select Role';

  // ========== Inquiry Form Validation Messages ==========
  static const String typeOfBookingRequired = 'Type of booking is required';
  static const String titleRequired = 'Title is required';
  static const String firstNameRequired = 'First name is required';
  static const String firstNameMinLength = 'First name must be at least 2 characters';
  static const String lastNameRequired = 'Last name is required';
  static const String lastNameMinLength = 'Last name must be at least 2 characters';
  static const String phoneNumberRequired = 'Phone number is required';
  static const String phoneNumberDigitsOnly = 'Phone number must contain only digits';
  static const String phoneNumberLength = 'Phone number must be between 6 and 15 digits';
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email address';
  static const String addressRequired = 'Address is required';
  static const String addressMinLength = 'Address must be at least 5 characters';
  static const String referenceNameRequired = 'Reference name is required';
  static const String referenceNameMinLength = 'Reference name must be at least 2 characters';
  static const String referenceNumberRequired = 'Reference number is required';
  static const String referenceNumberDigitsOnly = 'Reference number must contain only digits';
  static const String referenceNumberLength = 'Reference number must be between 6 and 15 digits';

  // ========== Inquiry Form Success/Error Messages ==========
  static const String inquirySubmittedSuccessfully = 'Inquiry submitted successfully!';
  static const String inquirySubmissionFailed = 'Failed to submit inquiry. Please try again.';

  // ========== Air Ticket Form ==========
  static const String airTicketForm = 'Air Ticket Form';
  static const String airTicketFormTitle = 'AIR TICKET FORM';
  static const String provideFlightBookingInformation = 'Provide flight booking information';
  static const String youCanReachUsAnytime = 'You can reach us anytime via kthplcrm@mail.com';

  // ========== Air Ticket Form Fields ==========
  static const String flightType = 'Flight Type';
  static const String from = 'From';
  static const String fromLabel = 'From';
  static const String to = 'To';
  static const String toLabel = 'To';
  static const String departure = 'Departure';
  static const String returnLabel = 'Return';
  static const String travellerAndClass = 'Traveller & Class';
  static const String typeOfVisa = 'Type of visa:';
  static const String remark = 'Remark';
  static const String setPriority = 'Set Priority:';
  static const String typeOfFollowUps = 'Type of follow ups';

  // ========== Air Ticket Form Hints ==========
  static const String selectDepartureDate = 'Select departure date';
  static const String selectReturnDate = 'Select return date';
  static const String enterFromLocation = 'Enter from location';
  static const String enterToLocation = 'Enter to location';
  static const String enterRemark = 'Enter remark';
  static const String selectTravellerCount = 'Select traveller count';
  static const String selectClass = 'Select class';
  static const String traveller = 'Traveller';
  static const String classLabel = 'Class';
  static const String selectFollowUpType = 'Select follow-up type';
  static const String selectDate = 'Select date';

  // ========== Air Ticket Form Validation Messages ==========
  static const String fromLocationRequired = 'From location is required';
  static const String fromLocationMinLength = 'From location must be at least 2 characters';
  static const String toLocationRequired = 'To location is required';
  static const String toLocationMinLength = 'To location must be at least 2 characters';
  static const String toLocationDifferent = 'To location must be different from From location';
  static const String departureDateRequired = 'Departure date is required';
  static const String departureDatePast = 'Departure date cannot be in the past';
  static const String returnDateRequired = 'Return date is required for Round Trip';
  static const String departureDateMustBeSet = 'Departure date must be set first';
  static const String returnDateAfterDeparture = 'Return date must be after departure date';
  static const String travellerCountRequired = 'At least 1 traveller is required';
  static const String travellerCountMax = 'Maximum 9 travellers allowed';
  static const String visaTypeRequired = 'Visa type is required';
  static const String remarkRequired = 'Remark is required';
  static const String remarkMinLength = 'Remark must be at least 3 characters';

  // ========== Air Ticket Form Success/Error Messages ==========
  static const String airTicketSubmittedSuccessfully = 'Air ticket booking submitted successfully!';
  static const String airTicketSubmissionFailed =
      'Failed to submit air ticket booking. Please try again.';

  // ========== Flight Booking Types ==========
  static const String oneWay = 'One Way';
  static const String roundTrip = 'Round Trip';
  static const String multiCity = 'Multi City';
  static const String flightBooking = 'Flight Booking';
  static const String hotelBooking = 'Hotel Booking';
  static const String cruiseBooking = 'Cruise Booking';
  static const String tourPackage = 'Tour Package';
  static const String visaAssistance = 'Visa Assistance';

  // ========== Travel Class Types ==========
  static const String economy = 'Economy';
  static const String business = 'Business';
  static const String first = 'First';

  // ========== Visa Types ==========
  static const String visitorVisa = 'Visitor Visa';
  static const String studentVisa = 'Student Visa';
  static const String pr = 'PR';
  static const String workPermit = 'Work Permit';

  // ========== Priority Types ==========
  static const String low = 'Low';
  static const String medium = 'Medium';
  static const String high = 'High';
  static const String urgent = 'Urgent';

  // ========== Follow-up Types ==========
  //static const String email = 'Email';
  static const String phoneCall = 'Phone Call';
  static const String sms = 'SMS';
  static const String whatsapp = 'WhatsApp';
  static const String inPerson = 'In-Person';

  // ========== Checklist ==========
  static const String addChecklist = 'Add Checklist';
  static const String user = 'User';
  static const String dueDate = 'Due Date';
  static const String category = 'Category';
  static const String inLoop = 'In Loop';
  static const String repeat = 'Repeat';

  // ========== Checklist Categories ==========
  static const String documentation = 'Documentation';
  static const String payment = 'Payment';
  static const String visa = 'Visa';
  static const String other = 'Other';

  // ========== Buttons & Actions ==========
  static const String submit = 'Submit';
  static const String search = 'Search';
  static const String addAnotherField = 'Add another field';
  static const String optForFullRefund = 'Opt for full refund.';

  // ========== Tooltips ==========
  static const String refresh = 'Refresh';
  static const String time = 'Time';
  static const String delete = 'Delete';

  // ========== Default Values ==========
  static const String defaultFromLocation = 'AMD - Ahmedabad';
  static const String defaultToLocation = 'GOI - GOA';
  static const String defaultAirportFrom = 'Sardar Vallabhbhai Patel International Airport';
  static const String defaultAirportTo = 'GOA Dabolim International Airport';
  static const String defaultDepartureDate = 'THU, 20 NOV';
  static const String defaultTraveller = '1 Traveller, Economy';

  // ========== Client Leads ==========
  static const String selected = 'Selected: ';
  static const String selectIfNeeded = 'Select if needed';
  static const String flexibleDate = 'Flexible date';
  static const String modifyWhenSearching = 'Modify when searching';

  // ========== Additional Services ==========
  static const String everythingNeedTitle = 'Everything you need for every trip.';
  static const String passportAssistance = 'Passport Assistance';
  static const String travelInsurance = 'Travel Insurance';
  static const String forex = 'Forex';
  static const String taxi = 'Taxi';
  static const String domesticPackage = 'Domestic Package';
  static const String internationalPackage = 'International Package';

  // ========== Amendment Information ==========
  static const String amendmentInformation = 'Amendment Information';
  static const String amendmentType = 'Amendment Type';
  static const String reIssue = 'Re-issue';
  static const String amendmentID = 'Amendment ID';
  static const String status = 'Status';
  static const String amountCharged = 'Amount Charged';
  static const String attachments = 'Attachments';
  static const String raisedBy = 'Raised By';
  static const String bookedBy = 'Booked By';
  static const String assignedStaff = 'Assigned Staff';
  static const String amendmentInvoice = 'Amendment Invoice';
  static const String remarks = 'Remarks';
  static const String generationTime = 'Generation Time';
  static const String checklist = 'Checklist';
  static const String nextTravelDate = 'Next Travel Date';
  static const String processedTime = 'Processed Time';
  static const String addNotes = 'Add Notes';
  static const String text = 'Text';
  static const String callAgent = 'Call Agent';
  static const String qnaNotes = 'Q&A Notes';
  static const String addNewNotes = 'Add New Notes';
  static const String questions = 'Questions.';
  static const String answers = 'Answers';
  static const String getPersonalDocumentDetails = 'Get Personal Document Details';
}
