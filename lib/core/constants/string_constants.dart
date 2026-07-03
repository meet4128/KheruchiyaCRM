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
  static const String inquiryManagement = 'New Inquiry';
  static const String projectJobs = 'Follow Up';
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

  // ========== Operations Portal (Login) ==========
  static const String operationsPortalTitle = 'OPERATIONS PORTAL';
  static const String loginWithKheruchiyaTravels = 'Login with Kheruchiya Travels';
  static const String loginAuthorizedAccessDisclaimer =
      'Authorized team access only. Sign in with admin-provided credentials.';
  static const String password = 'Password';
  static const String loginTooltipShowPassword = 'Show password';
  static const String loginTooltipHidePassword = 'Hide password';
  static const String keepMeSignedIn = 'Keep me signed in';
  static const String forgotPasswordQuestion = 'Forgot Password?';
  static const String loginContactAdministratorNote =
      "If you don't have login credentials, please contact your administrator.";
  static const String copyrightSymbol = '©';
  /// Use after year: `'$copyrightSymbol$year$loginFooterKthplCrmSuffix'`.
  static const String loginFooterKthplCrmSuffix = ' KTHPL CRM';
  static const String poweredByZeemoDigitalLine = 'Powered by ZEEMO DIGITAL';
  static const String cookies = 'COOKIES';
  static const String legalPolicies = 'LEGAL POLICIES';
  static const String loginFooterLinksSeparator = '  |  ';
  static const String loginAppVersionDisplay = 'Version 1.0.0';

  // ========== Inquiry Form ==========
  static const String inquiryForm = 'Inquiry Form';
  static const String inquiryFormTitle = 'INQUIRY FORM';
  static const String fillInFormForCustomerInquiry = 'Fill in the form for customer inquiry.';
  static const String newInquiry = 'New Inquiry';
  static const String search = 'Search';
  static const String lightMode = 'Light Mode';
  static const String defaultUserName = 'Riyan Doe';
  static const String fillFormForQuote =
      'Fill form for a quote, help or to assist client';
  static const String letsTalkAboutClients = "Let's talk about our\n";
  static const String project = "Client's project.";
  static const String inquiryFormDescription =
      "We'll create high-quality linkable content and build at least 40 high-authority link to each asset. Bring the way for you to grow your website & improve skills.";
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
  static const String fullName = 'Full Name';
  static const String typeOfClient = 'Type of Client';
  static const String clientBehaviour = 'Client Behaviour';
  static const String referenceNameLabel = 'Refrence Name'; // Display label as in design

  // ========== Inquiry Form Hints ==========
  static const String enterTitle = 'Enter title';
  static const String enterFirstName = 'Enter first name';
  static const String enterLastName = 'Enter last name';
  static const String enterPhoneNumber = 'Enter phone number';
  static const String enterEmail = 'Enter email';
  static const String enterAddress = 'Enter address';
  static const String enterReferenceName = 'Enter reference name';
  static const String enterReferenceNumber = 'Enter reference number';
  static const String enterFullName = 'Enter full name';
  static const String enterClientBehaviour = 'Enter client behaviour';
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
  static const String fullNameRequired = 'Full name is required';
  static const String clientBehaviourRequired = 'Client behaviour is required';

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
  /// Hint when no checklist priority is selected (no trailing colon).
  static const String setPriorityHint = 'Set Priority';
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
  static const String infantCountExceedsAdults =
      'Number of infants cannot exceed number of adults';
  static const String adultTravellerLabel = 'Adult (12+)';
  static const String childTravellerLabel = 'Child (2 to 12)';
  static const String infantTravellerLabel = 'Infant (0-2)';
  static const String visaTypeRequired = 'Visa type is required';
  static const String remarkRequired = 'Remark is required';
  static const String remarkMinLength = 'Remark must be at least 3 characters';

  // ========== Air Ticket Form Success/Error Messages ==========
  static const String airTicketSubmissionSuccessTitle = 'Success';
  /// Primary action on air ticket success dialog (pill button).
  static const String continueAction = 'Continue';
  static const String airTicketSubmittedSuccessfully = 'Air ticket booking submitted successfully!';
  static const String airTicketSubmissionFailed =
      'Failed to submit air ticket booking. Please try again.';

  // ========== Hotel Booking Form ==========
  static const String hotelBookingForm = 'Hotel Booking Form';
  static const String provideHotelBookingInformation = 'Provide hotel booking information';

  // ========== Hotel Booking Form Fields ==========
  static const String cityOrLocation = 'City or Location';
  static const String checkIn = 'Check-In';
  static const String checkOut = 'Check Out';
  static const String roomAndGuests = 'Room & Guests';
  static const String propertyType = 'Property Type';
  static const String hotelCategory = 'Hotel Category:';
  static const String roomView = 'Room View:';
  static const String amenities = 'Amenities';
  static const String mealPlan = 'Meal Plan:';
  static const String transfers = 'Transfers';
  static const String yourBudget = 'Your Budget';
  static const String rooms = 'Rooms';
  static const String adults = 'Adults';

  // ========== Hotel Booking Form Hints ==========
  static const String enterCityOrLocation = 'Enter city or location';
  static const String selectCheckInDate = 'Select check-in date';
  static const String selectCheckOutDate = 'Select check-out date';
  static const String budgetMin = 'Min';
  static const String budgetMax = 'Max';

  // ========== Hotel Booking Form Validation Messages ==========
  static const String cityRequired = 'City or location is required';
  static const String checkInRequired = 'Check-in date is required';
  static const String checkOutRequired = 'Check-out date is required';
  static const String checkOutAfterCheckIn = 'Check-out date must be after check-in date';
  static const String roomGuestsRequired = 'At least 1 room and 1 adult are required';
  static const String propertyTypeRequired = 'Property type is required';
  static const String hotelCategoryRequired = 'Hotel category is required';
  static const String budgetInvalid = 'Maximum budget must be greater than minimum budget';

  // ========== Hotel Booking Form Success/Error Messages ==========
  static const String hotelBookingSubmittedSuccessfully = 'Hotel booking submitted successfully!';
  static const String hotelBookingSubmissionFailed =
      'Failed to submit hotel booking. Please try again.';

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
  static const String addUsersTitle = 'Add users';
  static const String userTypeNamePressEnter = 'Type a name and press Enter';
  static const String done = 'Done';
  static const String dueDate = 'Due Date';
  static const String category = 'Category';
  static const String inLoop = 'In Loop';
  static const String repeat = 'Repeat';
  static const String voiceNoteTitle = 'Voice note';
  static const String voiceNoteHint = 'Tap the mic to record';
  static const String voiceNoteRecording = 'Recording…';
  static const String voiceNoteSaved = 'Recording saved';
  static const String microphonePermissionRequired =
      'Microphone permission is required to record a voice note.';
  static const String recordAgain = 'Record again';
  static const String playRecording = 'Play recording';
  static const String deleteRecording = 'Delete recording';
  static const String pausePlayback = 'Pause';

  // ========== Checklist Categories ==========
  static const String documentation = 'Documentation';
  static const String payment = 'Payment';
  static const String visa = 'Visa';
  static const String other = 'Other';

  // ========== Buttons & Actions ==========
  static const String submit = 'Submit';
  static const String addAnotherField = 'Add another field';
  static const String addAnotherCity = 'Add another City';
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
  static const String questionAndAnswer = 'Question & answer';
  static const String typeYourMessageHere = 'Type Your Message Here';
  static const String qnaChatYesterday = 'Yesterday';
  static const String qnaChatToday = 'TODAY';
  static const String qnaChatEmpty = 'No messages yet';
  static const String qnaChatAwaitingCustomerReply =
      'Waiting for customer reply on WhatsApp. If replies never appear, confirm the '
      'inquiry phone matches the customer\'s WhatsApp number and that the Meta webhook is receiving events.';
  static const String qnaChatLoadFailed = 'Could not load messages';
  static const String qnaChatRetry = 'Retry';
  static const String qnaChatAttach = 'Attachments and options';
  static const String qnaChatRemoveAttachment = 'Remove attachment';
  static const String qnaChatUploadingDocument = 'Uploading document…';
  static const String qnaChatDocumentSent = 'Document sent';
  static const String qnaChatSendMessageFirstForAttach =
      'Send a message first to start the chat session.';
  static const String qnaChatSendMessageFirstForNotes =
      'Send a message first to add session notes.';
  static const String qnaChatPhoneUnavailable =
      'Customer phone is not available. Messaging is disabled.';
  static const String qnaChatViewDocument = 'View';
  static const String qnaChatDownloadDocument = 'Download';
  static const String amendmentCardNotesTitle = 'Session notes';
  static const String downloadAmendmentInvoice = 'Download Amendment Invoice';
  static const String qnaChatClearAmendmentType = 'Clear amendment type';
  static const List<String> qnaChatAmendmentTypeOptions = [
    'Re Issue',
    'Cancellation',
    'Booking',
    'Baggage',
  ];
  static const String qnaChatPaymentStatus = 'Payment Status';
  static const String qnaChatPaymentStatusOneTime = 'One-Time';
  static const String qnaChatPaymentStatusInstallment = 'Installment';
  static const List<String> qnaChatPaymentStatusOptions = [
    qnaChatPaymentStatusOneTime,
    qnaChatPaymentStatusInstallment,
  ];
  static const String qnaChatPaymentTermsOf = 'Payment Terms of';
  static const String qnaChatInquiryInformation = 'Inquiry Information';
  static const String qnaChatEnterTravelDateTime = 'Enter Travel Date & Time';
  static const String qnaChatBookingType = 'Booking Type';
  static const String qnaChatTotalAmountToBeReceived = 'Total Amount to be received';
  static const String qnaChatInclusiveOfAllTaxes = 'Inclusive of all taxes';
  static const String qnaChatNoOfInstallments = 'No. of Installments';
  static const String qnaChatPaymentReceivedTillNow = 'Payment Received Till Now';
  static const List<String> qnaChatPaymentModeOptions = ['Cash', 'UPI', 'Cheque'];
  static const String qnaChatColumnAmount = 'Amount';
  static const String qnaChatColumnDueDate = 'Due Date';
  static const String qnaChatColumnReceivedDate = 'Recieved Date';
  static const String qnaChatColumnMode = 'Mode';
  static const String qnaChatColumnStatus = 'Status';
  static const String qnaChatColumnPaymentProof = 'Payment Proof';
  static const String qnaChatNotReceivedYet = 'Not Recieved Yet';
  static const String qnaChatOnTime = 'On-Time';
  static const String qnaChatLate = 'Late';
  static const String qnaChatUploadProof = 'Upload Proof';
  static const String qnaChatPaymentLateTooltip = 'Payment late';
  static const String qnaChatPaymentTermsFinalisedOn = 'Payment Terms Finalised on';
  static const String qnaChatInstallmentSingular = 'Installment';
  static const String qnaChatInstallmentPlural = 'Installments';
  static const String qnaChatRemainingAmount = 'Remaining amount';
  static const String qnaChatSave = 'Save';
  static const String qnaChatPaymentSaveSuccess = 'Payment terms saved.';
  static const String qnaChatPaymentSaveFailure = 'Could not save payment terms.';
  static const String qnaChatProofUploaded = 'Uploaded';
  static const String qnaGetPersonalDocumentDetails = 'Get Personal Document Details';
  static const String qnaTalkToPurchaseTeam = 'Talk To Purchase Team';
  static const String messagesTitle = 'Messages';
  static const String messagesBack = 'Back';
  static const String messagesBackToMembers = 'Back to members';
  static const String messagesSearchMembers = 'Search purchase team';
  static const String messagesNoMembers = 'No purchase team members found';
  static const String messagesDirectoryLoadFailed = 'Could not load purchase team directory';
  static const String messagesSelectMemberHint = 'Select a purchase team member to start chatting';
  static const String messagesSelectInquiryHint =
      'Open an inquiry and use Talk To Purchase Team to chat in context';
  static const String qnaPutFollowUp = 'Put Follow Up';
  static const String putFollowUpSubtitle = 'Set Reminder';
  static const String addFollowUpNote = 'Add Follow Up Note';
  static const String addFollowUpNoteHint = 'Enter follow up note';
  static const String putFollowUpSetDate = 'Set Date';
  static const String putFollowUpTime = 'Time';
  static const String putFollowUpSelectTime = 'Select time';
  static const String putFollowUpSelectAgent = 'Select Agent';
  static const String putFollowUpSelectUser = 'Select User';
  static const String saveFollowUpReminder = 'Save Follow up Reminder';
  static const String putFollowUpRepeat = 'Repeat';
  static const String putFollowUpSaveSuccess = 'Follow up reminder saved';
  static const String putFollowUpSaveErrorGeneric = 'Could not save follow up reminder';
  static const String putFollowUpNoteRequired = 'Follow up note is required';
  static const String putFollowUpAgentRequired = 'Please select an agent';
  static const String putFollowUpAgentsLoadFailed = 'Could not load agents';
  static const String putFollowUpRetryLoadAgents = 'Retry';
  static const String putFollowUpClearForm = 'Clear form';
  static const String attachment = 'Attachment';
  static const String qnaMarkAsPending = 'Mark as Pending';
  static const String qnaMarkAsLoss = 'Mark as Loss';
  static const String qnaMarkAsWon = 'Mark as Won';
  static const String qnaAmountChargedTitle = 'Amount charged';
  static const String qnaAmountChargedHint = 'Enter amount';
  static const String addNewNotes = 'Add New Notes';
  static const String questions = 'Questions.';
  static const String answers = 'Answers';
  static const String getPersonalDocumentDetails = 'Get Personal Document Details';
  static const String inquiryInformation = 'Inquiry Information:';
  static const String inquiryNumber = 'Inquiry Number:';
  static const String inquiryGenerated = 'Inquiry Generated:';
  static const String assignedTo = 'Assigned to:';
  static const String allTicketBookings = 'All Ticket Bookings';
  static const String allInvoices = 'All Invoices';
  static const String moreOptions = 'More Options';
  static const String priority = 'Priority:';
  static const String statusColon = 'Status:';
  static const String inProgress = 'In Progress';

  // ========== Admin — Add Member dialog ==========
  static const String addMemberDialogTitle = 'Add Member';
  static const String addMemberPersonalInformationTitle = 'Personal Information';
  static const String addMemberOperationInformationTitle = 'Operation Information';
  static const String addMemberFillFormSubtitle = 'Fill the form with correct details';
  static const String addMemberNext = 'Next';
  static const String addMemberBack = 'Back';
  static const String addMemberSubmit = 'Submit';
  static const String addMemberNextStepHelper =
      'Please fill all the required details and then click to the next to move on operational form';
  static const String addMemberSubmitFooterNote =
      'You can edit even after submitting this form using edit from action column';
  static const String addMemberTypeOfRole = 'Type of Role';
  static const String addMemberAddRoleButton = '+ Add Role';
  static const String addMemberAddRoleLabelCompact = 'Add Role';
  static const String addMemberRemoveRoleTooltip = 'Remove role';
  static const String addMemberAllottedLabel = 'Allotted';
  static const String addMemberOfficePhoneLabel = 'Office Phone Number';
  static const String addMemberOfficePhoneNumberHint = '123456789';
  static const String addMemberAttachDocuments = 'Attach Documents';
  static const String addMemberAttachmentAadhar = 'Aadhar card';
  static const String addMemberAttachmentPan = 'PAN Card';
  static const String addMemberAttachmentCancelCheque = 'Cancel Cheque';
  static const String addMemberAttachmentPickHint = 'Tap to attach';
  static const String addMemberEmployeeIdLabel = 'Employee ID';
  static const String addMemberEmployeeIdHint = 'Enter employee ID';
  static const String addMemberDesignationLabel = 'Designation';
  static const String addMemberDesignationHint = 'Enter your work designation';
  static const String addMemberEmploymentStatusLabel = 'Employment Status';
  static const String addMemberEmploymentStatusHint = 'Status';
  static const String addMemberDateOfJoiningLabel = 'Date of Joining';
  static const String addMemberDateOfJoiningHint = 'Select date of joining';
  static const String addMemberSelectDepartmentLabel = 'Select Department';
  static const String addMemberSelectDepartmentHint = 'Department';
  static const String addMemberSelectRoleLabel = 'Select Role';
  static const String addMemberSelectRoleHint = 'Role';
  static const String addMemberFirstNameHint = 'Enter first name';
  static const String addMemberLastNameHint = 'Enter last name';
  static const String addMemberEmployeeIdRequired = 'Employee ID is required';
  static const String addMemberDesignationRequired = 'Designation is required';
  static const String addMemberEmploymentStatusRequired = 'Employment status is required';
  static const String addMemberDateOfJoiningRequired = 'Date of joining is required';
  static const String addMemberRoleRowsIncomplete = 'Select department and role for each row.';
  static const String addMemberSubmitSuccessMessage = 'Member saved successfully.';
  static const String addMemberSubmitErrorGeneric = 'Something went wrong. Please try again.';

  // ========== Forgot Password ==========
  static const String forgotPasswordTitle = 'Reset Your Password';
  static const String forgotPasswordSubtitle =
      "Enter your email and we'll send you a link to reset your password.";
  static const String forgotPasswordEmailLabel = 'Email';
  static const String forgotPasswordSubmit = 'Send Reset Link';
  static const String forgotPasswordSentTitle = 'Check your email';
  static const String forgotPasswordSentSubtitle =
      "If an account exists for that email, we've sent a reset link. It expires in 30 minutes.";
  static const String forgotPasswordBackToLogin = 'Back to login';

  // ========== Set Password (Invite link landing) ==========
  static const String setPasswordVerifyingLink = 'Verifying your link…';
  static const String setPasswordTitle = 'Set Your Password';
  /// Replace `{email}` with the masked email returned by validate-token.
  static const String setPasswordSubtitleTemplate = 'Setting password for {email}';
  /// Replace `{dateTime}` with a formatted ISO date.
  static const String setPasswordLinkExpiresTemplate = 'This link expires on {dateTime}.';
  static const String setPasswordNewLabel = 'New password';
  static const String setPasswordConfirmLabel = 'Confirm password';
  static const String setPasswordSubmit = 'Set password';
  static const String setPasswordSuccessTitle = 'Password set';
  static const String setPasswordSuccessSubtitle =
      'You can now log in with your new password.';
  static const String setPasswordGoToLogin = 'Go to login';
  static const String setPasswordTooShort = 'Password must be at least 8 characters.';
  static const String setPasswordTooLong = 'Password must be at most 128 characters.';
  static const String setPasswordWeak =
      'Password must contain at least one letter and one digit.';
  static const String setPasswordMismatch = 'Passwords do not match.';
  static const String setPasswordRequired = 'Password is required';
  static const String setPasswordInvalidLinkTitle = 'Link is invalid';
  static const String setPasswordInvalidLinkBody =
      'This link is invalid. Please ask your admin for a new invitation.';
  static const String setPasswordExpiredLinkTitle = 'Link expired';
  static const String setPasswordExpiredLinkBody =
      'This invite link has expired. Ask your admin to resend it.';
  static const String setPasswordUsedLinkTitle = 'Link already used';
  static const String setPasswordUsedLinkBody =
      'This link has already been used. Try logging in instead.';
  static const String setPasswordRateLimited =
      'Too many attempts. Please try again later.';
  static const String setPasswordGenericError =
      'Could not set password. Please try again.';
  static const String setPasswordValidationFailedTitle = 'Verification failed';
  static const String setPasswordValidationFailedBody =
      "We couldn't verify this link. Check your connection and try again.";
  static const String setPasswordRetry = 'Try again';

  // ========== Reset Password ==========
  static const String resetPasswordTitle = 'Reset Your Password';
  static const String resetPasswordSubmit = 'Reset password';
  static const String resetPasswordSamePassword =
      'Please choose a different password than your current one.';
  static const String resetPasswordSuccessTitle = 'Password updated';
  static const String resetPasswordSuccessSubtitle =
      'You can now log in with your new password.';

  // ========== Add Member — Invite section ==========
  static const String addMemberInviteSectionTitle = 'Send invite email to:';
  static const String addMemberInviteSectionSubtitle =
      'The new member receives a magic link to set their password.';
  static const String addMemberInviteEmailPersonal = 'Personal email';
  static const String addMemberInviteEmailWork = 'Work email';
  static const String addMemberInviteEmailCustom = 'Other';
  static const String addMemberInviteEmailHint = 'Enter email address';
  static const String addMemberInviteEmailRequired = 'Please enter a valid email';
  static const String addMemberInviteEmailNoPersonalOnFile =
      'No personal email on file';
  static const String addMemberInviteEmailPersonalEmpty =
      'No personal email entered yet';
  static const String addMemberInviteEmailWorkUnavailable =
      'Not available (no work email on file)';
  static const String addMemberSendInviteToggle =
      "Don't send invite now (you can resend later)";
  static const String addMemberSubmittedNoInviteMessage =
      'Member created. Click "Resend invite" to send the invite later.';
  /// Dev-only hint surfaced when backend has no Resend API key configured.
  static const String addMemberInviteDevFallbackHint =
      '(dev: no Resend key — link logged to server console)';

  // ========== Team Members — Invite affordances ==========
  static const String teamMembersResendInviteTooltip = 'Resend invite';
  static const String teamMembersInviteResentMessage = 'Invite resent.';
  static const String teamMembersInviteResendFailed = 'Could not resend invite.';
  static const String teamMembersInviteAlreadyActive =
      'This member already set their password.';
  static const String teamMembersInviteResendRateLimit =
      'Wait a moment before resending again.';
  static const String teamMembersInviteStatusPending = 'Invite pending';
  static const String teamMembersInviteStatusDisabled = 'Disabled';

  // ========== Team members — delete member ==========
  static const String teamMembersDeleteConfirmTitle = 'Delete team member?';
  static String teamMembersDeleteConfirmMessage(String name, String email) =>
      'This will permanently remove $name${email.isNotEmpty ? ' ($email)' : ''}. '
      'This action cannot be undone.';
  static const String teamMembersDeleteConfirmButton = 'Delete member';
  static const String teamMembersDeleteCancelButton = 'Cancel';
  static const String teamMembersDeleteSuccessMessage = 'Member deleted.';
  static const String teamMembersDeleteFailedMessage = 'Could not delete member.';
  static const String addMemberDialogTitleEdit = 'Edit Member';
  static const String addMemberLoadMemberFailed =
      'Could not load member details. Try again.';
  static const String addMemberLoadingMember = 'Loading member…';
  static const String addMemberRetryLoadMember = 'Retry';
  static const String addMemberSubmitSaveChanges = 'Save changes';
  static const String addMemberUpdateSuccessMessage = 'Member updated successfully.';

  // ========== Auth — Generic / shared ==========
  static const String authInvalidCredentials = 'Invalid email or password.';
  static const String authTooManyAttempts =
      'Too many login attempts, please try again later.';

  /// Templated success snackbar after AddMember create. Replace `{email}`.
  /// Helper builders for templated strings.
  static String addMemberInviteSentMessage(String email) =>
      'Member created. Invite email sent to $email.';
}
