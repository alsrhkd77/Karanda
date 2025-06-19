import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/recruitment_join_status.dart';
import 'package:karanda/model/applicant.dart';
import 'package:karanda/ui/core/ui/button_loading_indicator.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';

class RecruitmentPostApplicantsTab extends StatelessWidget {
  final List<Applicant>? applicants;
  final Future<void> Function(String) accept;
  final Future<void> Function(String) reject;

  const RecruitmentPostApplicantsTab({
    super.key,
    this.applicants,
    required this.accept,
    required this.reject,
  });

  @override
  Widget build(BuildContext context) {
    if (applicants == null) {
      return const LoadingIndicator();
    } else if (applicants?.isEmpty ?? true) {
      return Center(
          child: Text(context.tr("adventurer hub.post.applicants empty")));
    }
    return PageBase(children: [
      ...applicants!.map((value) {
        return _ApplicantTile(data: value, accept: accept, reject: reject);
      }).toList(),
    ]);
  }
}

class _ApplicantTile extends StatelessWidget {
  final Applicant data;
  final Future<void> Function(String) accept;
  final Future<void> Function(String) reject;

  const _ApplicantTile({
    super.key,
    required this.data,
    required this.accept,
    required this.reject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Tooltip(
          message: "Access Code",
          child: Chip(label: Text(data.code)),
        ),
        title: Text(data.user.username),
        //subtitle: Text("⚔️ -"),
        trailing: _Tail(
          status: data.status,
          accept: () async {
            await accept(data.user.discordId);
          },
          reject: () async {
            await reject(data.user.discordId);
          },
        ),
      ),
    );
  }
}

class _Tail extends StatefulWidget {
  final RecruitmentJoinStatus status;
  final Future<void> Function() accept;
  final Future<void> Function() reject;

  const _Tail({
    super.key,
    required this.status,
    required this.accept,
    required this.reject,
  });

  @override
  State<_Tail> createState() => _TailState();
}

class _TailState extends State<_Tail> {
  bool isLoading = false;

  Future<void> accept() async {
    setState(() {
      isLoading = true;
    });
    await widget.accept();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> reject() async {
    setState(() {
      isLoading = true;
    });
    await widget.reject();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: ButtonLoadingIndicator(),
      );
    } else if (widget.status == RecruitmentJoinStatus.cancelled) {
      return Chip(
        label: Text(
          context.tr(
            "adventurer hub.recruitment join status.${widget.status.name}",
          ),
        ),
        backgroundColor: Colors.red,
        surfaceTintColor: Colors.white,
        side: BorderSide.none,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: widget.status == RecruitmentJoinStatus.pending ||
                  widget.status == RecruitmentJoinStatus.accepted
              ? reject
              : null,
          tooltip: context.tr("adventurer hub.post.reject"),
          icon: const Icon(Icons.close),
          color: Colors.grey,
          disabledColor: Colors.red,
          hoverColor: Colors.red,
        ),
        IconButton(
          onPressed: widget.status == RecruitmentJoinStatus.pending ||
              widget.status == RecruitmentJoinStatus.rejected
              ? accept
              : null,
          tooltip: context.tr("adventurer hub.post.accept"),
          icon: const Icon(Icons.check),
          color: Colors.grey,
          disabledColor: Colors.blue,
          hoverColor: Colors.blue,
        ),
      ],
    );
  }
}
