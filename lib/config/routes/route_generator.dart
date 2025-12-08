import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/config/routes/smooth_page_route.dart';
import 'package:bizzhrms_flutter_app/presentation/auth/view/sign_in_page.dart';
import 'package:bizzhrms_flutter_app/presentation/home/view/home_page.dart';
import 'package:bizzhrms_flutter_app/presentation/dashboard/view/dashboard_page.dart';
import 'package:bizzhrms_flutter_app/presentation/attendance/view/attendance_page.dart';
import 'package:bizzhrms_flutter_app/presentation/leaves/view/leaves_page.dart';
import 'package:bizzhrms_flutter_app/presentation/projects/view/projects_page.dart';
import 'package:bizzhrms_flutter_app/presentation/projects/view/project_details_page.dart';
import 'package:bizzhrms_flutter_app/presentation/announcements/view/announcements_page.dart';
import 'package:bizzhrms_flutter_app/presentation/complaints/view/complaints_page.dart';
import 'package:bizzhrms_flutter_app/presentation/work_report/view/work_report_page.dart';
import 'package:bizzhrms_flutter_app/presentation/profile/view/profile_page.dart';
import 'package:bizzhrms_flutter_app/presentation/profile/view/change_password_page.dart';
import 'package:bizzhrms_flutter_app/presentation/admin_employees/view/admin_employees_page.dart';
import 'package:bizzhrms_flutter_app/presentation/admin_attendance_filtered/view/admin_attendance_filtered_page.dart';
import 'package:bizzhrms_flutter_app/presentation/admin_leave_management/view/admin_leave_management_page.dart';
import 'package:bizzhrms_flutter_app/presentation/splash/view/splash_page.dart';
import 'package:bizzhrms_flutter_app/presentation/awards/view/awards_page.dart';
import 'package:bizzhrms_flutter_app/presentation/tickets/view/tickets_page.dart';
import 'package:bizzhrms_flutter_app/presentation/payroll/view/payroll_page.dart';
import 'package:bizzhrms_flutter_app/presentation/training/view/training_page.dart';
import 'package:bizzhrms_flutter_app/presentation/performance/view/performance_page.dart';
import 'package:bizzhrms_flutter_app/presentation/transfers/view/transfers_page.dart';
import 'package:bizzhrms_flutter_app/presentation/promotions/view/promotions_page.dart';
import 'package:bizzhrms_flutter_app/presentation/warnings/view/warnings_page.dart';
import 'package:bizzhrms_flutter_app/presentation/travels/view/travels_page.dart';
import 'package:bizzhrms_flutter_app/presentation/office_shift/view/office_shift_page.dart';
import 'package:bizzhrms_flutter_app/presentation/job_applied/view/job_applied_page.dart';
import 'package:bizzhrms_flutter_app/presentation/job_interview/view/job_interview_page.dart';
import 'package:bizzhrms_flutter_app/presentation/payslips/view/payslips_page.dart';
import 'package:bizzhrms_flutter_app/presentation/advance_salary/view/advance_salary_page.dart';
import 'package:bizzhrms_flutter_app/presentation/advance_salary_report/view/advance_salary_report_page.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/pages/placeholder_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Custom route generator that uses SmoothPageRoute for snappy transitions
class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeSplash:
        return SmoothPageRoute(
          builder: (context) => const SplashPage(),
          settings: settings,
        );
      case AppConstants.routeSignIn:
        return SmoothPageRoute(
          builder: (context) => const SignInPage(),
          settings: settings,
        );
      case AppConstants.routeHome:
        return SmoothPageRoute(
          builder: (context) => const HomePage(),
          settings: settings,
        );
      case AppConstants.routeDashboard:
        return SmoothPageRoute(
          builder: (context) => const DashboardPage(),
          settings: settings,
        );
      case AppConstants.routeAttendance:
        return SmoothPageRoute(
          builder: (context) => const AttendancePage(),
          settings: settings,
        );
      case AppConstants.routeLeaves:
        return SmoothPageRoute(
          builder: (context) => const LeavesPage(),
          settings: settings,
        );
      case AppConstants.routeProjects:
        return SmoothPageRoute(
          builder: (context) => const ProjectsPage(),
          settings: settings,
        );
      case AppConstants.routeProjectDetails:
        final project = settings.arguments as Map<String, dynamic>?;
        if (project == null) {
          return SmoothPageRoute(
            builder: (context) => const ProjectsPage(),
            settings: settings,
          );
        }
        return SmoothPageRoute(
          builder: (context) => ProjectDetailsPage(project: project),
          settings: settings,
        );
      case AppConstants.routeAnnouncements:
        return SmoothPageRoute(
          builder: (context) => const AnnouncementsPage(),
          settings: settings,
        );
      case AppConstants.routeComplaints:
        return SmoothPageRoute(
          builder: (context) => const ComplaintsPage(),
          settings: settings,
        );
      case AppConstants.routeWorkReport:
        return SmoothPageRoute(
          builder: (context) => const WorkReportPage(),
          settings: settings,
        );
      case AppConstants.routeProfile:
        return SmoothPageRoute(
          builder: (context) => const ProfilePage(),
          settings: settings,
        );
      case AppConstants.routeChangePassword:
        return SmoothPageRoute(
          builder: (context) => const ChangePasswordPage(),
          settings: settings,
        );
      case AppConstants.routeAdminEmployees:
        return SmoothPageRoute(
          builder: (context) => const AdminEmployeesPage(),
          settings: settings,
        );
      case AppConstants.routeAdminAttendanceFiltered:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            args['statusTime'] == null ||
            args['date'] == null) {
          return SmoothPageRoute(
            builder: (context) => const HomePage(),
            settings: settings,
          );
        }
        return SmoothPageRoute(
          builder: (context) => AdminAttendanceFilteredPage(
            statusTime: args['statusTime'] as String,
            date: args['date'] as String,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminLeaveManagement:
        return SmoothPageRoute(
          builder: (context) => const AdminLeaveManagementPage(),
          settings: settings,
        );
      case AppConstants.routeAwards:
        return SmoothPageRoute(
          builder: (context) => const AwardsPage(),
          settings: settings,
        );
      case AppConstants.routeTickets:
        return SmoothPageRoute(
          builder: (context) => const TicketsPage(),
          settings: settings,
        );
      case AppConstants.routePayroll:
        return SmoothPageRoute(
          builder: (context) => const PayrollPage(),
          settings: settings,
        );
      case AppConstants.routePayslips:
        return SmoothPageRoute(
          builder: (context) => const PayslipsPage(),
          settings: settings,
        );
      case AppConstants.routeAdvanceSalary:
        return SmoothPageRoute(
          builder: (context) => const AdvanceSalaryPage(),
          settings: settings,
        );
      case AppConstants.routeAdvanceSalaryReport:
        return SmoothPageRoute(
          builder: (context) => const AdvanceSalaryReportPage(),
          settings: settings,
        );
      case AppConstants.routeTraining:
        return SmoothPageRoute(
          builder: (context) => const TrainingPage(),
          settings: settings,
        );
      case AppConstants.routePerformance:
        return SmoothPageRoute(
          builder: (context) => const PerformancePage(),
          settings: settings,
        );
      case AppConstants.routeTransfers:
        return SmoothPageRoute(
          builder: (context) => const TransfersPage(),
          settings: settings,
        );
      case AppConstants.routePromotions:
        return SmoothPageRoute(
          builder: (context) => const PromotionsPage(),
          settings: settings,
        );
      case AppConstants.routeWarnings:
        return SmoothPageRoute(
          builder: (context) => const WarningsPage(),
          settings: settings,
        );
      case AppConstants.routeTravels:
        return SmoothPageRoute(
          builder: (context) => const TravelsPage(),
          settings: settings,
        );
      case AppConstants.routeOfficeShift:
        return SmoothPageRoute(
          builder: (context) => const OfficeShiftPage(),
          settings: settings,
        );
      case AppConstants.routeJobApplied:
        return SmoothPageRoute(
          builder: (context) => const JobAppliedPage(),
          settings: settings,
        );
      case AppConstants.routeJobInterview:
        return SmoothPageRoute(
          builder: (context) => const JobInterviewPage(),
          settings: settings,
        );
      // Admin Routes - Placeholder pages
      case AppConstants.routeAdminSetRoles:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Set Roles',
            icon: FontAwesomeIcons.userShield,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminResignations:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Resignations',
            icon: FontAwesomeIcons.fileContract,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminTerminations:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Terminations',
            icon: FontAwesomeIcons.userXmark,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminEmployeesLastLogin:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Employees Last Login',
            icon: FontAwesomeIcons.clockRotateLeft,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminEmployeesExit:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Employees Exit',
            icon: FontAwesomeIcons.doorOpen,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminCompany:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Company',
            icon: FontAwesomeIcons.building,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminBranch:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Branch',
            icon: FontAwesomeIcons.sitemap,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminDepartment:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Department',
            icon: FontAwesomeIcons.briefcase,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminDesignation:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Designation',
            icon: FontAwesomeIcons.idCard,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminPolicies:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Policies',
            icon: FontAwesomeIcons.fileLines,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminExpense:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Expense',
            icon: FontAwesomeIcons.moneyBill,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminPerformanceIndicator:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Performance Indicator',
            icon: FontAwesomeIcons.chartLine,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminPerformanceAppraisal:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Performance Appraisal',
            icon: FontAwesomeIcons.chartBar,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminPayrollTemplates:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Payroll Templates',
            icon: FontAwesomeIcons.calculator,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminHourlyWages:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Hourly Wages',
            icon: FontAwesomeIcons.clock,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminManageSalary:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Manage Salary',
            icon: FontAwesomeIcons.moneyBillWave,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminAdvanceSalary:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Advance Salary',
            icon: FontAwesomeIcons.handHoldingDollar,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminAdvanceSalaryReport:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Advance Salary Report',
            icon: FontAwesomeIcons.fileInvoiceDollar,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminGeneratePayslip:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Generate Payslip',
            icon: FontAwesomeIcons.fileInvoice,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminPaymentHistory:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Payment History',
            icon: FontAwesomeIcons.history,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminJobPosts:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Job Posts',
            icon: FontAwesomeIcons.briefcase,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminJobCandidates:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Job Candidates',
            icon: FontAwesomeIcons.userTie,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminTrainingType:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Training Type',
            icon: FontAwesomeIcons.graduationCap,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminTrainers:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Trainers',
            icon: FontAwesomeIcons.personChalkboard,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminFilesManager:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Files Manager',
            icon: FontAwesomeIcons.folder,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminEmployeesDirectory:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Employees Directory',
            icon: FontAwesomeIcons.addressBook,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminAccounts:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Accounts',
            icon: FontAwesomeIcons.buildingColumns,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminTransactions:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Transactions',
            icon: FontAwesomeIcons.exchange,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminReports:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Reports',
            icon: FontAwesomeIcons.chartBar,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminSettings:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Settings',
            icon: FontAwesomeIcons.gear,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminConstants:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Constants',
            icon: FontAwesomeIcons.list,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminDatabaseBackup:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Database Backup',
            icon: FontAwesomeIcons.database,
          ),
          settings: settings,
        );
      case AppConstants.routeAdminEmailTemplates:
        return SmoothPageRoute(
          builder: (context) => const PlaceholderPage(
            title: 'Email Templates',
            icon: FontAwesomeIcons.envelope,
          ),
          settings: settings,
        );
      default:
        return SmoothPageRoute(
          builder: (context) => const SignInPage(),
          settings: settings,
        );
    }
  }
}
