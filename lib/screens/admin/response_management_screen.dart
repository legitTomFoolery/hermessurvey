import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gsecsurvey/models/question.dart';
import 'package:gsecsurvey/models/survey_response.dart';
import 'package:gsecsurvey/screens/admin/widgets/expandable_response_card.dart';
import 'package:gsecsurvey/services/firestore_service.dart';
import 'package:gsecsurvey/services/response_admin_service.dart';

class ResponseManagementScreen extends StatefulWidget {
  const ResponseManagementScreen({Key? key}) : super(key: key);

  @override
  State<ResponseManagementScreen> createState() =>
      _ResponseManagementScreenState();
}

class _ResponseManagementScreenState extends State<ResponseManagementScreen> {
  List<SurveyResponse> _responses = [];
  List<Question> _questions = [];
  bool _isLoading = true;
  String? _expandedResponseId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load both responses and questions in parallel
      final results = await Future.wait([
        ResponseAdminService.getAllResponses(),
        FirestoreService.getQuestionsOnce(),
      ]);

      final responses = results[0] as List<SurveyResponse>;
      final questionsSnapshot = results[1] as QuerySnapshot<Question>;
      final questions =
          questionsSnapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        _responses = responses;
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onResponseExpanded(String responseId) {
    setState(() {
      _expandedResponseId = responseId;
    });
  }

  void _onResponseCollapsed() {
    setState(() {
      _expandedResponseId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _responses.isEmpty
                ? _buildEmptyState()
                : _buildResponsesList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No survey responses found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Survey responses will appear here once users submit surveys',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsesList() {
    return Column(
      children: [
        // Header with count
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.assignment,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                '${_responses.length} Survey Response${_responses.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Responses list
        Expanded(
          child: ListView.builder(
            itemCount: _responses.length,
            itemBuilder: (context, index) {
              final response = _responses[index];
              return ExpandableResponseCard(
                response: response,
                questions: _questions,
                onUpdate: _loadData,
                isExpanded: _expandedResponseId == response.id,
                onExpanded: () => _onResponseExpanded(response.id),
                onCollapsed: _onResponseCollapsed,
              );
            },
          ),
        ),
      ],
    );
  }
}
