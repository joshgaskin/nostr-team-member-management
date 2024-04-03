class NostrTeamUtils {
  static bool isValidUriFormat(String input) {
    try {
      Uri.parse(input);
      return true;
    } catch (e) {
      return false;
    }
  }
}
