import 'package:flutter/material.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';

class PostItem extends StatelessWidget {
  final int index;
  final String id;
  final String title;
  final String image;
  final String date;
  final String author;
  final String authorImage;
  final void Function(String id) onTapCallback;

  const PostItem({
    super.key,
    required this.index,
    required this.id,
    required this.title,
    required this.image,
    required this.date,
    required this.author,
    required this.authorImage,
    required this.onTapCallback,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTapCallback(id),
      child: Card(
        elevation: 0.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        margin:
            const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0).copyWith(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.3,
                                  color: Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child:
                                    authorImage.isNotEmpty
                                        ? Image.network(
                                          ApiClient.getAsset(authorImage),
                                          height: 35,
                                          width: 35,
                                          fit: BoxFit.cover,
                                        )
                                        : Container(
                                          height: 35,
                                          width: 35,
                                          color: Colors.grey[300],
                                        ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(author, style: TextStyle(fontSize: 12)),
                                SizedBox(height: 5),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        image.isNotEmpty
                            ? Image.network(
                              ApiClient.getAsset(image),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              height: 100,
                              width: 100,
                              color: Colors.grey[300],
                            ),
                  ),
                ],
              ),
            ),
            Container(
              height: 0.5,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(color: Colors.grey[300]),
            ),
          ],
        ),
      ),
    );
  }
}
