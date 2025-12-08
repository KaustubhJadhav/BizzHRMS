// Base model class for all data models
abstract class BaseModel {
  Map<String, dynamic> toJson();
  // fromJson will be implemented by each model
}

