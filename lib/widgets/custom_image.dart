import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

cachedNetworkImage(mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) => Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.blue[400]),)),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}