class Event {
  final int id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String? location;
  final String eventType;
  final String? imageUrl;
  final String creatorFirstName;
  final String creatorLastName;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    this.location,
    required this.eventType,
    this.imageUrl,
    required this.creatorFirstName,
    required this.creatorLastName,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      eventDate: DateTime.parse(json['event_date']),
      location: json['location'],
      eventType: json['event_type'],
      imageUrl: json['image_url'],
      creatorFirstName: json['creator_first_name'] ?? '',
      creatorLastName: json['creator_last_name'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get creatorName => '$creatorFirstName $creatorLastName'.trim();

  String get eventTypeDisplayName {
    switch (eventType) {
      case 'match':
        return 'Match';
      case 'training':
        return 'Training';
      case 'meeting':
        return 'Meeting';
      case 'tournament':
        return 'Tournament';
      case 'announcement':
        return 'Announcement';
      default:
        return eventType;
    }
  }

  String get eventTypeIcon {
    switch (eventType) {
      case 'match':
        return '⚽';
      case 'training':
        return '🏃';
      case 'meeting':
        return '📅';
      case 'tournament':
        return '🏆';
      case 'announcement':
        return '📢';
      default:
        return '📅';
    }
  }
}

class EventsResponse {
  final List<Event> events;
  final EventsPagination pagination;

  EventsResponse({required this.events, required this.pagination});

  factory EventsResponse.fromJson(Map<String, dynamic> json) {
    return EventsResponse(
      events: (json['events'] as List)
          .map((eventJson) => Event.fromJson(eventJson))
          .toList(),
      pagination: EventsPagination.fromJson(json['pagination']),
    );
  }
}

class EventsPagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNext;
  final bool hasPrev;

  EventsPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory EventsPagination.fromJson(Map<String, dynamic> json) {
    return EventsPagination(
      currentPage: json['current_page'],
      totalPages: json['total_pages'],
      totalItems: json['total_items'],
      itemsPerPage: json['items_per_page'],
      hasNext: json['has_next'],
      hasPrev: json['has_prev'],
    );
  }
}
