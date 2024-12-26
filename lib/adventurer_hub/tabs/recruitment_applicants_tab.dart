import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/adventurer_hub/models/applicant.dart';
import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/adventurer_hub/widgets/applicant_status_chip.dart';
import 'package:karanda/common/enums/applicant_status.dart';
import 'package:karanda/widgets/button_loading_indicator.dart';
import 'package:karanda/widgets/custom_base.dart';
import 'package:karanda/widgets/family_name_widget.dart';
import 'package:karanda/widgets/loading_indicator.dart';

class RecruitmentApplicantsTab extends StatefulWidget {
  final Recruitment post;
  final Stream<List<Applicant>> stream;
  final void Function() initFunction;
  final Future<void> Function(String) approveFunction;
  final Future<void> Function(String) rejectFunction;

  const RecruitmentApplicantsTab({
    super.key,
    required this.post,
    required this.stream,
    required this.initFunction,
    required this.approveFunction,
    required this.rejectFunction,
  });

  @override
  State<RecruitmentApplicantsTab> createState() =>
      _RecruitmentApplicantsTabState();
}

class _RecruitmentApplicantsTabState extends State<RecruitmentApplicantsTab> {
  String keyword = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => widget.initFunction());
  }

  bool filter(Applicant item) {
    if (item.code != null && item.code!.contains(keyword)) {
      return true;
    } else if (item.user.mainFamily!.familyName.contains(keyword)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        }
        List<Applicant> filtered = snapshot.requireData.where(filter).toList()
          ..sort((a, b) => a.appliedAt.compareTo(b.appliedAt));
        return CustomBase(
          children: [
            _Summary(
              current: widget.post.currentParticipants,
              max: widget.post.maximumParticipants,
              applicants: snapshot.requireData.length,
            ),
            _SearchBar(
              onChanged: (value) {
                setState(() {
                  keyword = value;
                });
              },
            ),
            snapshot.requireData.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      context
                          .tr("recruitment post detail.applicants are empty"),
                      textAlign: TextAlign.center,
                    ),
                  )
                : const SizedBox(),
            snapshot.requireData.isNotEmpty && filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      context.tr("recruitment post detail.search not found"),
                      textAlign: TextAlign.center,
                    ),
                  )
                : const SizedBox(),
            ...filtered.map(
              (data) => _ApplicantTile(
                applicant: data,
                approveFunction: widget.approveFunction,
                rejectFunction: widget.rejectFunction,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  final void Function(String) onChanged;

  const _SearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          label: Text(context.tr("recruitment post detail.search")),
          hintText: context.tr("recruitment post detail.search bar hint"),
        ),
      ),
    );
  }
}

class _ApplicantTile extends StatelessWidget {
  final Applicant applicant;
  final Future<void> Function(String) approveFunction;
  final Future<void> Function(String) rejectFunction;

  const _ApplicantTile({
    super.key,
    required this.applicant,
    required this.approveFunction,
    required this.rejectFunction,
  });

  Widget? tail(BuildContext context) {
    if (applicant.status == ApplicantStatus.applied) {
      return _Tail(
        target: applicant.user.discordId,
        approveFunction: approveFunction,
        rejectFunction: rejectFunction,
      );
    } else if (applicant.status == ApplicantStatus.approved) {
      return Text(
        context.tr(
          "recruitment post detail.code",
          args: [applicant.code ?? ""],
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4.0),
      child: ListTile(
        leading: ApplicantStatusChip(status: applicant.status),
        title: FamilyNameWidget(family: applicant.user.mainFamily!),
        trailing: tail(context),
      ),
    );
  }
}

class _Tail extends StatefulWidget {
  final String target;
  final Future<void> Function(String) approveFunction;
  final Future<void> Function(String) rejectFunction;

  const _Tail({
    super.key,
    required this.target,
    required this.approveFunction,
    required this.rejectFunction,
  });

  @override
  State<_Tail> createState() => _TailState();
}

class _TailState extends State<_Tail> {
  bool request = false;

  Future<void> approve() async {
    setState(() {
      request = true;
    });
    await widget.approveFunction(widget.target);
    setState(() {
      request = false;
    });
  }

  Future<void> reject() async {
    setState(() {
      request = true;
    });
    await widget.rejectFunction(widget.target);
    setState(() {
      request = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (request) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: ButtonLoadingIndicator(),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: reject,
          icon: const Icon(Icons.cancel_outlined),
          color: Colors.red,
          tooltip: context.tr("recruitment post detail.action.reject"),
        ),
        IconButton(
          onPressed: approve,
          icon: const Icon(Icons.check_circle_outline),
          color: Colors.green,
          tooltip: context.tr("recruitment post detail.action.approve"),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  final int current;
  final int max;
  final int applicants;

  const _Summary({
    super.key,
    required this.current,
    required this.max,
    required this.applicants,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            context.tr(
              "recruitment post detail.applicants count",
              args: [applicants.toString()],
            ),
          ),
          Text(
            context.tr(
              "recruitment post detail.current count",
              args: [current.toString()],
            ),
          ),
          Text(
            context.tr(
              "recruitment post detail.max count",
              args: [max.toString()],
            ),
          ),
        ],
      ),
    );
  }
}
