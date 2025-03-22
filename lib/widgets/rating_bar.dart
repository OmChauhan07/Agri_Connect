import 'package:flutter/material.dart';

// Widget for displaying rating only (not interactive)
class RatingBarDisplay extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  
  const RatingBarDisplay({
    Key? key,
    required this.rating,
    this.size = 20,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          // Full star
          return Icon(Icons.star, color: color, size: size);
        } else if (index == rating.floor() && rating % 1 != 0) {
          // Half star
          return Icon(Icons.star_half, color: color, size: size);
        } else {
          // Empty star
          return Icon(Icons.star_border, color: color, size: size);
        }
      }),
    );
  }
}

// Interactive rating bar for user input
class RatingBar extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final double size;
  final Color color;
  
  const RatingBar({
    Key? key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 30,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  State<RatingBar> createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  late double _rating;
  
  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        
        return GestureDetector(
          onTap: () => _updateRating(starValue),
          child: Icon(
            starValue <= _rating
                ? Icons.star
                : (starValue - 0.5) <= _rating && _rating < starValue
                    ? Icons.star_half
                    : Icons.star_border,
            color: widget.color,
            size: widget.size,
          ),
        );
      }),
    );
  }
  
  void _updateRating(double value) {
    setState(() {
      _rating = value;
    });
    widget.onRatingChanged(value);
  }
}
