/// Databases Response Model
class DatabasesResponse {
  DatabasesResponse({this.data, this.serverVersion});

  List<String>? data;
  String? serverVersion;

  factory DatabasesResponse.fromList(
    List<dynamic> list, {
    String? serverVersion,
  }) => DatabasesResponse(
    data: list.map((e) => e.toString()).toList(),
    serverVersion: serverVersion,
  );

  Map<String, dynamic> toJson() => {
    "data": data,
    "server_version": serverVersion,
  };
}
