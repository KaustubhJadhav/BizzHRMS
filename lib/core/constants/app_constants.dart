class AppConstants {
  // API Endpoints
  // static const String baseUrl = 'https://arena.creativecrows.co.in/api1/';
  static const String baseUrl = 'https://hrms.bizz100.com/api1/';
  static const String loginEndpoint = 'auth/login';
  static const String logoutEndpoint = 'auth/logout';
  static const String userInfoEndpoint = 'user/get_info';
  static const String changePasswordEndpoint = 'user/change_password';
  static const String updateProfileEndpoint = 'user/update_profile';
  static const String dashboardEndpoint = 'dashboard';
  static const String attendanceEndpoint = 'attendance/get_attendance';
  static const String monthAttendanceEndpoint = 'attendance/month_log';
  static const String setClockingEndpoint = 'attendance/set_clocking';
  static const String leaveListEndpoint = 'leave/list';
  static const String leaveAddEndpoint = 'leave/add';
  static const String taskListEndpoint = 'workreport/task_list';
  static const String projectListEndpoint = 'project/project_list';
  static const String projectUpdateStatusEndpoint = 'project/update_status';
  static const String projectSetDiscussionEndpoint = 'project/set_discussion';
  static const String projectDiscussionListEndpoint = 'project/discussion_list';
  static const String projectBugListEndpoint = 'project/bug_list';
  static const String announcementListEndpoint =
      'announcement/announcement_list';
  static const String awardsListEndpoint = 'api_common/getAwardList';
  static const String awardDetailEndpoint = 'api_common/getAwardDetailById';
  static const String transferListEndpoint = 'api_common/getTransferList';
  static const String transferDetailEndpoint =
      'api_common/getTransferDetailById';
  static const String promotionListEndpoint = 'api_common/getPromotionList';
  static const String promotionDetailEndpoint =
      'api_common/getPromotionDetailById';
  static const String jobAppliedListEndpoint = 'api_common/getJobAppliedList';
  static const String jobInterviewListEndpoint =
      'api_common/getJobInterviewList';
  static const String complaintListEndpoint = 'api_common/getComplaintList';
  static const String complaintDetailEndpoint =
      'api_common/getComplaintDetailById';
  static const String warningListEndpoint = 'api_common/getWarningList';
  static const String warningDetailEndpoint = 'api_common/getWarningDetailById';
  static const String travelListEndpoint = 'api_common/getTravelList';
  static const String travelDetailEndpoint = 'api_common/getTravelDetailById';
  static const String officeShiftListEndpoint = 'api_common/getOfficeShiftList';
  static const String trainingListEndpoint = 'api_common/getTrainingList';
  static const String trainingDetailEndpoint =
      'api_common/getTrainingDetailById';
  static const String ticketListEndpoint = 'api_ticket/getTicketList';
  static const String ticketDetailEndpoint = 'api_ticket/getTicketDetailById';
  static const String addTicketEndpoint = 'api_ticket/add_ticket';
  static const String editTicketEndpoint = 'api_ticket/edit_ticket';
  static const String addTicketCommentEndpoint =
      'api_ticket/add_ticket_comment';
  static const String deleteTicketCommentEndpoint =
      'api_ticket/delete_ticket_comment';
  static const String addTicketAttachmentEndpoint =
      'api_ticket/add_ticket_attachment';
  static const String deleteTicketAttachmentEndpoint =
      'api_ticket/delete_ticket_attachment';
  static const String saveFCMTokenEndpoint = 'attendance/save_fcm_token';
  static const String adminDashboardEndpoint = 'admin/dashboard/';
  static const String adminEmployeesEndpoint = 'admin/employees';
  static const String adminAttendanceFilteredEndpoint =
      'admin/dashboard/attendance_all_employees';
  static const String adminLeaveEndpoint = 'admin/leave/';
  static const String adminLeaveAddEndpoint = 'admin/leave/add_leave';
  static const String adminLeaveEditEndpoint = 'admin/leave/edit_leave';
  static const String adminLeaveDeleteEndpoint = 'admin/leave/delete_leave';
  static const String adminLeaveUpdateStatusEndpoint =
      'admin/leave/update_leave_status';
  static const String employeePermissionEndpoint =
      'attendance/employee_permission';

  // Storage Keys
  static const String keyUserToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyUsername = 'username';

  // App Info
  static const String appName = 'BizzHRMS';
  static const String appVersion = '1.0.0';

  // Navigation Routes
  static const String routeSplash = '/';
  static const String routeSignIn = '/sign-in';
  static const String routeHome = '/home';
  static const String routeDashboard = '/dashboard';
  static const String routeAttendance = '/attendance';
  static const String routeLeaves = '/leaves';
  static const String routeProjects = '/projects';
  static const String routeProjectDetails = '/project-details';
  static const String routeAnnouncements = '/announcements';
  static const String routeComplaints = '/complaints';
  static const String routeComplaintDetails = '/complaint-details';
  static const String routeWorkReport = '/work-report';
  static const String routeProfile = '/profile';
  static const String routeChangePassword = '/change-password';
  static const String routeAdminEmployees = '/admin-employees';
  static const String routeAdminAttendanceFiltered =
      '/admin-attendance-filtered';
  static const String routeAdminLeaveManagement = '/admin-leave-management';
  static const String routeAwards = '/awards';
  static const String routeTickets = '/tickets';
  static const String routeTicketDetails = '/ticket-details';
  static const String routePayroll = '/payroll';
  static const String routePayslips = '/payslips';
  static const String routeAdvanceSalary = '/advance-salary';
  static const String routeAdvanceSalaryReport = '/advance-salary-report';
  static const String routeTraining = '/training';
  static const String routeTrainingDetails = '/training-details';
  static const String routePerformance = '/performance';
  static const String routeTransfers = '/transfers';
  static const String routePromotions = '/promotions';
  static const String routeWarnings = '/warnings';
  static const String routeWarningDetails = '/warning-details';
  static const String routeTravels = '/travels';
  static const String routeTravelDetails = '/travel-details';
  static const String routeOfficeShift = '/office-shift';
  static const String routeJobApplied = '/job-applied';
  static const String routeJobInterview = '/job-interview';

  // Admin Routes
  static const String routeAdminSetRoles = '/admin-set-roles';
  static const String routeAdminResignations = '/admin-resignations';
  static const String routeAdminTerminations = '/admin-terminations';
  static const String routeAdminEmployeesLastLogin =
      '/admin-employees-last-login';
  static const String routeAdminEmployeesExit = '/admin-employees-exit';
  static const String routeAdminCompany = '/admin-company';
  static const String routeAdminBranch = '/admin-branch';
  static const String routeAdminDepartment = '/admin-department';
  static const String routeAdminDesignation = '/admin-designation';
  static const String routeAdminPolicies = '/admin-policies';
  static const String routeAdminExpense = '/admin-expense';
  static const String routeAdminPerformanceIndicator =
      '/admin-performance-indicator';
  static const String routeAdminPerformanceAppraisal =
      '/admin-performance-appraisal';
  static const String routeAdminPayrollTemplates = '/admin-payroll-templates';
  static const String routeAdminHourlyWages = '/admin-hourly-wages';
  static const String routeAdminManageSalary = '/admin-manage-salary';
  static const String routeAdminAdvanceSalary = '/admin-advance-salary';
  static const String routeAdminAdvanceSalaryReport =
      '/admin-advance-salary-report';
  static const String routeAdminGeneratePayslip = '/admin-generate-payslip';
  static const String routeAdminPaymentHistory = '/admin-payment-history';
  static const String routeAdminJobPosts = '/admin-job-posts';
  static const String routeAdminJobCandidates = '/admin-job-candidates';
  static const String routeAdminTrainingType = '/admin-training-type';
  static const String routeAdminTrainers = '/admin-trainers';
  static const String routeAdminFilesManager = '/admin-files-manager';
  static const String routeAdminEmployeesDirectory =
      '/admin-employees-directory';
  static const String routeAdminAccounts = '/admin-accounts';
  static const String routeAdminTransactions = '/admin-transactions';
  static const String routeAdminReports = '/admin-reports';
  static const String routeAdminSettings = '/admin-settings';
  static const String routeAdminConstants = '/admin-constants';
  static const String routeAdminDatabaseBackup = '/admin-database-backup';
  static const String routeAdminEmailTemplates = '/admin-email-templates';

  // Date Formats
  static const String dateFormatDisplay = 'dd-MMM-yyyy';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String dateTimeFormatDisplay = 'dd-MMM-yyyy hh:mm a';
}
