import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_downloader/simple_downloader.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/file_view_page.dart';

enum DownloadStatus { readyToDownload, downloading, paused, downloaded }

const int byteDivider = 1048576;

class TicketListItem extends StatefulWidget {
  final String title;
  final String url;

  const TicketListItem({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  State<TicketListItem> createState() => _TicketListItemState();
}

class _TicketListItemState extends State<TicketListItem> {
  late final SimpleDownloader downloader;
  DownloadStatus downloadStatus = DownloadStatus.readyToDownload;
  late final String fullPath;
  int _offset = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final String fileName = widget.title.replaceAll(' ', '').toLowerCase();
    var tempDir = await getTemporaryDirectory();
    fullPath = '${tempDir.path}/$fileName/$fileName.pdf';

    DownloaderTask task = DownloaderTask(
      url: widget.url,
      fileName: '$fileName.pdf',
      downloadPath: '${tempDir.path}/$fileName',
    );

    if (!mounted) return;

    downloader = SimpleDownloader.init(task: task);

    downloader.callback.addListener(() {
      setState(() {
        _total = downloader.callback.total;
        _offset = downloader.callback.offset;
        if (_total > 0 && _offset == _total) {
          downloadStatus = DownloadStatus.downloaded;
        }
      });
    });
  }

  @override
  void dispose() {
    downloader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    switch (downloadStatus) {
      case DownloadStatus.readyToDownload:
        icon = Icons.cloud_download_outlined;
        break;
      case DownloadStatus.downloading:
        icon = Icons.pause_circle_outline;
        break;
      case DownloadStatus.paused:
        icon = Icons.play_circle_outline;
        break;
      case DownloadStatus.downloaded:
        icon = Icons.cloud_done;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.airplane_ticket_outlined,
            color: Color(0xFF757575),
            size: 28,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: _total > 0 ? _offset / _total : 0,
                  backgroundColor: const Color(0xFFD1C4E9),
                ),
                const SizedBox(height: 4),
                Text(
                  getDownloadingStatusDescription(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: handleDownloadButton,
            icon: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: handleViewFileButton,
            icon: Icon(
              Icons.description_rounded,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  String getDownloadingStatusDescription() {
    switch (downloadStatus) {
      case DownloadStatus.readyToDownload:
        return 'Ожидает начала загрузки';
      case DownloadStatus.downloading:
      case DownloadStatus.paused:
        return 'Загружается ${(_offset / byteDivider).toStringAsFixed(1)} из ${(_total / byteDivider).toStringAsFixed(1)}';
      case DownloadStatus.downloaded:
        return 'Файл загружен';
    }
  }

  void handleDownloadButton() {
    switch (downloadStatus) {
      case DownloadStatus.readyToDownload:
        downloader.download();
        setState(() {
          downloadStatus = DownloadStatus.downloading;
        });
        break;
      case DownloadStatus.downloading:
        downloader.pause();
        setState(() {
          downloadStatus = DownloadStatus.paused;
        });
        break;
      case DownloadStatus.paused:
        downloader.resume();
        setState(() {
          downloadStatus = DownloadStatus.downloading;
        });
        break;
      default:
    }
  }

  void handleViewFileButton() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewFilePage(path: fullPath),
      ),
    );
  }
}
