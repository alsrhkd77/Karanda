import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/utils/api_endpoints/discord_api.dart';
import 'package:karanda/utils/external_links.dart';
import 'package:karanda/utils/launch_url.dart';

class HomeLinksSection extends StatelessWidget {
  final int count;
  final double childAspectRatio;

  const HomeLinksSection({
    super.key,
    required this.count,
    required this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: count,
      childAspectRatio: childAspectRatio,
      children: [
        _LinkTile(
          name: context.tr("home.external links.official"),
          imagePath: 'assets/icons/bdo.png',
          url: ExternalLinks.bdoOfficial,
        ),
        _LinkTile(
          name: context.tr("home.external links.lab"),
          imagePath: 'assets/icons/bdo.png',
          url: ExternalLinks.bdoLab,
        ),
        _LinkTile(
          name: context.tr("home.external links.inven"),
          imagePath: 'assets/icons/inven.png',
          url: ExternalLinks.bdoInven,
        ),
        _LinkTile(
          name: context.tr("home.external links.inven map"),
          imagePath: 'assets/icons/inven.png',
          url: ExternalLinks.bdoInvenMap,
        ),
        _LinkTile(
          name: context.tr("home.external links.garmoth"),
          imagePath: 'assets/icons/garmoth.png',
          url: ExternalLinks.garmoth,
        ),
        _LinkTile(
          name: context.tr("home.external links.codex"),
          imagePath: 'assets/icons/bdocodex.png',
          url: ExternalLinks.bdoCodex,
        ),
        _LinkTile(
          name: context.tr("home.external links.bdolytics"),
          imagePath: 'assets/icons/bdolytics.png',
          url: ExternalLinks.bdolytics,
        ),
        _LinkTile(
          name: context.tr("home.external links.ontop"),
          imagePath: 'assets/icons/onTopReplica.png',
          url: ExternalLinks.onTopReplica,
        ),
        _LinkTile(
          name: context.tr("home.external links.karanda discord"),
          imagePath: 'assets/icons/discord.png',
          url: DiscordApi.karandaChannel,
        ),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String name;
  final String imagePath;
  final String url;

  const _LinkTile({
    super.key,
    required this.name,
    required this.imagePath,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListTile(
        title: Text(name),
        leading: Image.asset(
          imagePath,
          height: 25,
          width: 25,
          fit: BoxFit.contain,
        ),
        onTap: () => launchURL(url),
      ),
    );
  }
}
