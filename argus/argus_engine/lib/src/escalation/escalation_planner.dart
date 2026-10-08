import '../schema/models.dart';

class ScheduledEscalationStep {
  final int incidentId;
  final int stepIndex;
  final DateTime executeAt;
  final String notifyTarget;
  final String message;

  const ScheduledEscalationStep({
    required this.incidentId,
    required this.stepIndex,
    required this.executeAt,
    required this.notifyTarget,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'incidentId': incidentId,
        'stepIndex': stepIndex,
        'executeAt': executeAt.toIso8601String(),
        'notifyTarget': notifyTarget,
        'message': message,
      };

  factory ScheduledEscalationStep.fromJson(Map<String, dynamic> json) =>
      ScheduledEscalationStep(
        incidentId: json['incidentId'] as int,
        stepIndex: json['stepIndex'] as int,
        executeAt: DateTime.parse(json['executeAt'] as String),
        notifyTarget: json['notifyTarget'] as String,
        message: json['message'] as String,
      );
}

/// Escalation planner generating timeline steps from rule specifications.
class EscalationPlanner {
  const EscalationPlanner();

  /// Computes all planned escalation steps for an incident given its rule specification.
  List<ScheduledEscalationStep> plan({
    required Incident incident,
    required RuleSpec rule,
  }) {
    if (rule.escalation.isEmpty) return const [];

    final steps = <ScheduledEscalationStep>[];
    for (int i = 0; i < rule.escalation.length; i++) {
      final esc = rule.escalation[i];
      final executeAt = incident.openedAt.add(Duration(seconds: esc.afterSec));

      steps.add(ScheduledEscalationStep(
        incidentId: incident.id,
        stepIndex: i,
        executeAt: executeAt,
        notifyTarget: esc.notify,
        message: esc.message.isNotEmpty
            ? esc.message
            : 'Escalation for incident #${incident.id}: ${incident.summary}',
      ));
    }

    return steps;
  }

  /// Determines if a scheduled step should execute given current incident status.
  bool shouldExecuteStep(Incident incident) {
    // Only unacknowledged, open incidents escalate
    return incident.status == IncidentStatus.open;
  }
}
