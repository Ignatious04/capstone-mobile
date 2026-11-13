enum ServiceTypeEnum { medical, police, fire }

ServiceTypeEnum? tryParseServiceType(String? value) {
  for (final t in ServiceTypeEnum.values) {
    if (t.name == value) return t;
  }
  return null;
}
