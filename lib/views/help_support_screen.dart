import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/auth_controller.dart';
import '../services/help_support_service.dart';
import '../services/email_service.dart';
import '../utils/loading_dialog_helper.dart';
import 'email_configuration_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.help_center,
                    size: 60,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find answers to common questions or contact our support team',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions Section
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.live_help,
                          title: 'Live Chat',
                          subtitle: 'Chat with support',
                          color: Colors.green,
                          onTap: () => _showLiveChatDialog(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.email,
                          title: 'Email Support',
                          subtitle: 'Send us an email',
                          color: Colors.blue,
                          onTap: () => _sendEmail(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // FAQ Section
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildFAQSection(),

                  const SizedBox(height: 30),

                  // Contact Information Section
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildContactCard(
                    icon: Icons.phone,
                    title: 'Phone Support',
                    subtitle: '+1 (555) 123-4567',
                    description: 'Available Mon-Fri, 9 AM - 6 PM EST',
                    color: Colors.orange,
                    onTap: () => _makePhoneCall('+15551234567'),
                  ),
                  const SizedBox(height: 16),

                  _buildContactCard(
                    icon: Icons.email,
                    title: 'Email Support',
                    subtitle: 'support@electroapp.com',
                    description: 'We respond within 24 hours',
                    color: Colors.blue,
                    onTap: () => _sendEmail(),
                  ),
                  const SizedBox(height: 16),

                  _buildContactCard(
                    icon: Icons.web,
                    title: 'Online Help Center',
                    subtitle: 'Visit our knowledge base',
                    description: 'Browse tutorials and guides',
                    color: Colors.purple,
                    onTap: () => _openWebsite('https://help.electroapp.com'),
                  ),

                  const SizedBox(height: 30),

                  // Feedback Section
                  const Text(
                    'Feedback',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildContactCard(
                    icon: Icons.rate_review,
                    title: 'Send Feedback',
                    subtitle: 'Help us improve the app',
                    description: 'Share your thoughts and suggestions',
                    color: Colors.teal,
                    onTap: () => _showFeedbackDialog(context),
                  ),
                  const SizedBox(height: 16),

                  _buildContactCard(
                    icon: Icons.bug_report,
                    title: 'Report a Bug',
                    subtitle: 'Found an issue?',
                    description: 'Let us know about any problems',
                    color: Colors.red,
                    onTap: () => _showBugReportDialog(context),
                  ),
                  const SizedBox(height: 16),

                  _buildContactCard(
                    icon: Icons.settings,
                    title: 'Email Configuration',
                    subtitle: 'Setup email notifications',
                    description: 'Configure admin email for feedback & bug reports',
                    color: Colors.indigo,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmailConfigurationScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return FutureBuilder<List<Map<String, String>>>(
      future: HelpSupportService.getFAQs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final faqs = snapshot.data ?? HelpSupportService.getDefaultFAQs();

        return Column(
          children: faqs
              .map((faq) => _buildFAQItem(
                    question: faq['question']!,
                    answer: faq['answer']!,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        iconColor: const Color(0xFF1E3A8A),
        collapsedIconColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showLiveChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.live_help, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text('Live Chat'),
            ],
          ),
          content: const Text(
            'Live chat feature is coming soon! For immediate assistance, please use phone or email support.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    String selectedCategory = 'General';
    final categories = [
      'General',
      'Bug Report',
      'Feature Request',
      'UI/UX',
      'Performance'
    ];

    // Capture the screen context before showing dialog
    final screenContext = context;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.rate_review, color: Color(0xFF1E3A8A)),
                  SizedBox(width: 8),
                  Text('Send Feedback'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('We\'d love to hear your thoughts!'),
                    const SizedBox(height: 16),
                    const Text('Category:'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Feedback:'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Share your feedback here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (feedbackController.text.trim().isNotEmpty) {
                      // Close the dialog first
                      Navigator.of(dialogContext).pop();

                      // Show loading dialog using screen context
                      LoadingDialogHelper.showLoadingDialog(screenContext, 
                          message: 'Submitting feedback...');

                      try {
                        // Get current user information
                        final authController =
                            Provider.of<AuthController>(screenContext, listen: false);
                        final userId =
                            authController.currentUser?.id ?? 'anonymous';
                        final userEmail = 
                            authController.currentUser?.email ?? 'unknown@email.com';
                        final userName = 
                            authController.currentUser?.name ?? 'Unknown User';

                        // Submit feedback with email notification
                        final success = await HelpSupportService.submitFeedback(
                          userId: userId,
                          feedback: feedbackController.text.trim(),
                          category: selectedCategory,
                          userEmail: userEmail,
                          userName: userName,
                        );

                        // Hide loading dialog
                        LoadingDialogHelper.hideLoadingDialog();

                        // Wait a moment for the loading dialog to fully disappear
                        await Future.delayed(const Duration(milliseconds: 300));

                        // Show success or error dialog using screen context
                        if (success) {
                          LoadingDialogHelper.showSuccessDialog(
                            screenContext,
                            title: 'Feedback Sent!',
                            message: 'Thank you for your feedback!\n\nYour message has been successfully sent to our admin team. We appreciate your input and will review it carefully.',
                          );
                        } else {
                          ScaffoldMessenger.of(screenContext).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to submit feedback. Please try again.'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                      } catch (e) {
                        // Hide loading dialog on error
                        LoadingDialogHelper.hideLoadingDialog();
                        
                        // Show error dialog using screen context
                        showDialog(
                          context: screenContext,
                          builder: (BuildContext errorDialogContext) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              title: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red[600]),
                                  const SizedBox(width: 10),
                                  const Text('Error'),
                                ],
                              ),
                              content: Text('Failed to send feedback: ${e.toString()}'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(errorDialogContext).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final TextEditingController bugController = TextEditingController();
    final TextEditingController stepsController = TextEditingController();

    // Capture the screen context before showing dialog
    final screenContext = context;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.bug_report, color: Colors.red),
              SizedBox(width: 8),
              Text('Report a Bug'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please describe the issue you encountered:'),
                const SizedBox(height: 16),
                const Text('Bug Description:'),
                const SizedBox(height: 8),
                TextField(
                  controller: bugController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Describe the bug or issue...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Steps to Reproduce (optional):'),
                const SizedBox(height: 8),
                TextField(
                  controller: stepsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: '1. Go to...\n2. Click on...\n3. See error...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (bugController.text.trim().isNotEmpty) {
                  // Close the dialog first
                  Navigator.of(dialogContext).pop();

                  // Show loading dialog using screen context
                  LoadingDialogHelper.showLoadingDialog(screenContext, 
                      message: 'Submitting bug report...');

                  try {
                    // Get current user information
                    final authController =
                        Provider.of<AuthController>(screenContext, listen: false);
                    final userId = authController.currentUser?.id ?? 'anonymous';
                    final userEmail = 
                        authController.currentUser?.email ?? 'unknown@email.com';
                    final userName = 
                        authController.currentUser?.name ?? 'Unknown User';

                    // Get device information
                    final deviceInfo = EmailService.getDeviceInfo();

                    // Submit bug report with email notification
                    final success = await HelpSupportService.submitBugReport(
                      userId: userId,
                      description: bugController.text.trim(),
                      deviceInfo: deviceInfo,
                      steps: stepsController.text.trim().isNotEmpty
                          ? stepsController.text.trim()
                          : null,
                      userEmail: userEmail,
                      userName: userName,
                    );

                    // Hide loading dialog
                    LoadingDialogHelper.hideLoadingDialog();

                    // Wait a moment for the loading dialog to fully disappear
                    await Future.delayed(const Duration(milliseconds: 300));

                    // Show success or error dialog using screen context
                    if (success) {
                      LoadingDialogHelper.showSuccessDialog(
                        screenContext,
                        title: 'Bug Report Sent!',
                        message: 'Thank you for reporting this issue!\n\nYour bug report has been successfully sent to our admin team. We will investigate and work on fixing it as soon as possible.',
                      );
                    } else {
                      ScaffoldMessenger.of(screenContext).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to submit bug report. Please try again.'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                  } catch (e) {
                    // Hide loading dialog on error
                    LoadingDialogHelper.hideLoadingDialog();
                    
                    // Show error dialog using screen context
                    showDialog(
                      context: screenContext,
                      builder: (BuildContext errorDialogContext) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          title: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red[600]),
                              const SizedBox(width: 10),
                              const Text('Error'),
                            ],
                          ),
                          content: Text('Failed to send bug report: ${e.toString()}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(errorDialogContext).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Copy to clipboard as fallback
        await Clipboard.setData(ClipboardData(text: phoneNumber));
        _showInfoSnackBar('Phone number copied to clipboard');
      }
    } catch (e) {
      // Copy to clipboard as fallback
      await Clipboard.setData(ClipboardData(text: phoneNumber));
      _showInfoSnackBar('Phone number copied to clipboard');
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@electroapp.com',
      query: 'subject=ElectroApp Support Request',
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Copy to clipboard as fallback
        await Clipboard.setData(
            const ClipboardData(text: 'support@electroapp.com'));
        _showInfoSnackBar('Email address copied to clipboard');
      }
    } catch (e) {
      // Copy to clipboard as fallback
      await Clipboard.setData(
          const ClipboardData(text: 'support@electroapp.com'));
      _showInfoSnackBar('Email address copied to clipboard');
    }
  }

  Future<void> _openWebsite(String url) async {
    final Uri websiteUri = Uri.parse(url);
    try {
      if (await canLaunchUrl(websiteUri)) {
        await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
      } else {
        // Copy to clipboard as fallback
        await Clipboard.setData(ClipboardData(text: url));
        _showInfoSnackBar('Website URL copied to clipboard');
      }
    } catch (e) {
      // Copy to clipboard as fallback
      await Clipboard.setData(ClipboardData(text: url));
      _showInfoSnackBar('Website URL copied to clipboard');
    }
  }

  void _showInfoSnackBar(String message) {
    // Note: This method needs context, so it should be called from a method that has access to BuildContext
    // For now, we'll just print the message
    print(message);
  }
}
