enum SearchType {
  title,
  actor,
  director,
  genre,
  year,
}

extension SearchTypeInfo on SearchType {
  String get title {
    switch (this) {
      case SearchType.title:
        return 'عنوان';

      case SearchType.actor:
        return 'بازیگر';

      case SearchType.director:
        return 'کارگردان';

      case SearchType.genre:
        return 'ژانر';

      case SearchType.year:
        return 'سال';
    }
  }

  String get hint {
    switch (this) {
      case SearchType.title:
        return 'نام فیلم یا سریال';

      case SearchType.actor:
        return 'نام بازیگر، مثلاً Cillian Murphy';

      case SearchType.director:
        return 'نام کارگردان، مثلاً Christopher Nolan';

      case SearchType.genre:
        return 'نام ژانر، مثلاً Drama';

      case SearchType.year:
        return 'سال انتشار، مثلاً 2024';
    }
  }
}
