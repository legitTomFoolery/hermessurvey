# Admin Panel

The admin panel provides comprehensive administrative functionality for managing surveys, users, and responses in the GSEC Survey App. It offers a complete dashboard for survey administration and analytics.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [User Management](#user-management)
- [Survey Management](#survey-management)
- [Response Management](#response-management)
- [Notification System](#notification-system)
- [Data Export](#data-export)
- [Security](#security)
- [API Reference](#api-reference)

## 🎯 Overview

The admin panel is a comprehensive administrative interface that provides:

- **User Management**: Create, edit, and manage user accounts and permissions
- **Survey Creation**: Dynamic survey builder with multiple question types
- **Response Analytics**: View, filter, and analyze survey responses
- **Notification Management**: Send targeted notifications to users
- **Data Export**: Export survey data in multiple formats
- **Real-time Updates**: Live data synchronization with Firebase

## 🏗️ Architecture

### Directory Structure

```
lib/features/admin/
├── data/                           # Data layer
│   ├── models/                    # Data models
│   │   ├── admin_user_model.dart  # User data model
│   │   └── admin_user_extended_model.dart # Extended user model
│   └── services/                  # Business services
│       ├── admin_service.dart     # Core admin operations
│       ├── admin_management_service.dart # User management
│       ├── response_admin_service.dart # Response management
│       └── response_export_service.dart # Data export
└── presentation/                   # UI layer
    ├── screens/                   # Main admin screens
    │   ├── main_admin_screen_with_bottom_nav.dart
    │   ├── user_management_screen.dart
    │   ├── question_management_screen.dart
    │   ├── response_management_screen.dart
    │   └── submission_summary_screen.dart
    └── widgets/                   # Reusable admin widgets
        ├── cards/                 # Card components
        ├── common/                # Common widgets
        ├── layout/                # Layout components
        ├── modals/                # Modal dialogs
        └── question_card_components/ # Question builder widgets
```

### Key Components

#### Admin Services
- **AdminService**: Core administrative operations
- **AdminManagementService**: User account management
- **ResponseAdminService**: Survey response handling
- **ResponseExportService**: Data export functionality

#### UI Components
- **Expandable Cards**: User, question, and response cards with detailed views
- **Filter Widgets**: Advanced filtering for responses and users
- **Modal Dialogs**: Notification creation and management
- **Layout Components**: Consistent admin interface layout

## ✨ Features

### Dashboard Overview
- **User Statistics**: Total users, active users, admin count
- **Survey Metrics**: Total surveys, response rates, completion statistics
- **Recent Activity**: Latest user registrations and survey submissions
- **Quick Actions**: Common administrative tasks

### Navigation
- **Bottom Navigation**: Easy access to main admin sections
- **Responsive Design**: Optimized for both mobile and desktop
- **Breadcrumb Navigation**: Clear navigation hierarchy

## 👥 User Management

### User Overview
- **User List**: Comprehensive list of all registered users
- **Search & Filter**: Find users by name, email, or role
- **User Details**: Expandable cards with detailed user information
- **Role Management**: Promote/demote admin privileges

### User Operations

#### View User Details
```dart
// User information displayed in expandable cards
- Email address and verification status
- Registration date and last login
- Admin status and permissions
- Survey completion history
```

#### Admin Role Management
```dart
// Promote user to admin
await AdminManagementService.promoteToAdmin(userId);

// Remove admin privileges
await AdminManagementService.removeAdminPrivileges(userId);
```

#### User Account Actions
- **Account Status**: Enable/disable user accounts
- **Password Reset**: Send password reset emails
- **Account Deletion**: Remove user accounts (with confirmation)

### User Statistics
- **Total Registered Users**: Count of all users in system
- **Active Users**: Users who have logged in recently
- **Admin Users**: Count of users with admin privileges
- **Verification Status**: Email verification statistics

## 📝 Survey Management

### Question Builder
- **Dynamic Question Creation**: Add, edit, and remove survey questions
- **Multiple Question Types**: 
  - Text input
  - Multiple choice
  - Rating scales
  - Date/time pickers
  - File uploads

### Question Management Features

#### Question Types
```dart
enum QuestionType {
  text,
  multipleChoice,
  rating,
  date,
  file,
  dropdown,
  checkbox
}
```

#### Question Configuration
- **Required Fields**: Mark questions as mandatory
- **Validation Rules**: Set input validation criteria
- **Conditional Logic**: Show/hide questions based on responses
- **Question Ordering**: Drag-and-drop question reordering

### Survey Operations
- **Create Survey**: Build new surveys from scratch
- **Edit Survey**: Modify existing survey questions
- **Publish Survey**: Make surveys available to users
- **Archive Survey**: Remove surveys from active use

### Question Card Components
- **Basic Fields**: Title, description, and type selection
- **Options Field**: Multiple choice and dropdown options
- **Validation Settings**: Input validation and requirements
- **Rotation Management**: Question rotation and randomization

## 📊 Response Management

### Response Overview
- **Response List**: All survey submissions with filtering
- **Response Details**: Expandable cards showing complete responses
- **User Attribution**: Link responses to specific users
- **Submission Timeline**: Track response submission times

### Filtering & Search
- **Date Range**: Filter responses by submission date
- **User Filter**: View responses from specific users
- **Question Filter**: Filter by specific question responses
- **Status Filter**: Complete vs. incomplete responses

### Response Analytics
- **Completion Rates**: Track survey completion statistics
- **Response Trends**: Analyze response patterns over time
- **Question Analytics**: Individual question response analysis
- **User Engagement**: Track user participation metrics

### Response Operations
```dart
// Get filtered responses
List<SurveyResponse> responses = await ResponseAdminService
    .getFilteredResponses(
  dateRange: DateRange(start: startDate, end: endDate),
  userId: selectedUserId,
  questionId: selectedQuestionId,
);

// Export responses
await ResponseExportService.exportToExcel(responses);
```

## 🔔 Notification System

### Notification Management
- **Create Notifications**: Send targeted messages to users
- **Notification Templates**: Pre-built message templates
- **User Targeting**: Send to specific users or groups
- **Scheduling**: Schedule notifications for future delivery

### Notification Features
- **Push Notifications**: Mobile push notification support
- **Email Notifications**: Email-based notification system
- **In-App Notifications**: App-based notification display
- **Notification History**: Track sent notifications

### Notification Modal
```dart
// Notification creation interface
- Message content and title
- Target user selection
- Delivery method selection
- Scheduling options
```

## 📤 Data Export

### Export Formats
- **Excel (.xlsx)**: Comprehensive spreadsheet export
- **CSV**: Comma-separated values for data analysis
- **JSON**: Raw data export for developers
- **PDF**: Formatted reports for presentations

### Export Features
- **Filtered Export**: Export only filtered data
- **Custom Fields**: Select specific fields to export
- **Date Range Export**: Export data from specific time periods
- **Batch Export**: Export large datasets efficiently

### Export Service
```dart
class ResponseExportService {
  static Future<void> exportToExcel(List<SurveyResponse> responses) async {
    // Create Excel workbook
    // Format data for export
    // Save and share file
  }
  
  static Future<void> exportToCSV(List<SurveyResponse> responses) async {
    // Convert to CSV format
    // Save and share file
  }
}
```

## 🔒 Security

### Access Control
- **Admin-Only Access**: All admin features require admin privileges
- **Role Verification**: Continuous verification of admin status
- **Secure Operations**: All operations require proper authentication

### Data Protection
- **Audit Logging**: Track all administrative actions
- **Data Validation**: Validate all input data
- **Secure Deletion**: Proper data cleanup for deleted records

### Permission Levels
```dart
// Admin permission checks
if (await UserService.isCurrentUserAdmin()) {
  // Allow admin operations
} else {
  // Redirect to unauthorized page
}
```

## 📚 API Reference

### AdminService

#### `getUserStatistics()`
Get comprehensive user statistics.

**Returns:** `Future<UserStatistics>`

#### `getSurveyMetrics()`
Get survey completion and response metrics.

**Returns:** `Future<SurveyMetrics>`

### AdminManagementService

#### `getAllUsers()`
Retrieve all registered users.

**Returns:** `Future<List<AdminUserModel>>`

#### `promoteToAdmin(String userId)`
Grant admin privileges to a user.

**Parameters:**
- `userId`: Target user ID

**Returns:** `Future<void>`

#### `removeAdminPrivileges(String userId)`
Remove admin privileges from a user.

**Parameters:**
- `userId`: Target user ID

**Returns:** `Future<void>`

### ResponseAdminService

#### `getFilteredResponses(ResponseFilter filter)`
Get survey responses with filtering.

**Parameters:**
- `filter`: Filter criteria object

**Returns:** `Future<List<SurveyResponse>>`

#### `deleteResponse(String responseId)`
Delete a specific survey response.

**Parameters:**
- `responseId`: Response ID to delete

**Returns:** `Future<void>`

### ResponseExportService

#### `exportToExcel(List<SurveyResponse> responses)`
Export responses to Excel format.

**Parameters:**
- `responses`: List of responses to export

**Returns:** `Future<void>`

## 🧪 Testing

### Admin Panel Testing
```bash
# Run admin-specific tests
flutter test test/unit/admin/

# Test admin widgets
flutter test test/widget/admin/
```

### Test Coverage Areas
- **User Management**: CRUD operations for users
- **Survey Management**: Question creation and editing
- **Response Management**: Filtering and export functionality
- **Security**: Admin privilege verification

## 🚀 Usage Examples

### Admin Dashboard Setup
```dart
class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainAdminScreenWithBottomNav(),
      bottomNavigationBar: AdminBottomNavigation(),
    );
  }
}
```

### User Management Example
```dart
class UserManagementScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdminUserModel>>(
      future: AdminManagementService.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ExpandableUserCard(
                user: snapshot.data![index],
                onPromoteToAdmin: (userId) => 
                    AdminManagementService.promoteToAdmin(userId),
              );
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

## 📝 Best Practices

1. **Always verify admin privileges** before allowing access
2. **Implement proper error handling** for all admin operations
3. **Use confirmation dialogs** for destructive operations
4. **Provide clear feedback** for all administrative actions
5. **Log administrative activities** for audit purposes

## 🔗 Related Documentation

- [Authentication System](../auth/README.md)
- [Survey Interface](../home/README.md)
- [Main App Documentation](../../README.md)

---

**Last Updated**: January 2025  
**Version**: 2.0.0
