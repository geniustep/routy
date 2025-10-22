/// Version Info Response Model
class VersionInfoResponse {
  VersionInfoResponse({
    this.serverVersionInfo,
    this.serverVersion,
    this.serverSerie,
    this.protocolVersion,
  });

  List<int>? serverVersionInfo;
  String? serverVersion;
  String? serverSerie;
  int? protocolVersion;

  factory VersionInfoResponse.fromJson(Map<String, dynamic> json) =>
      VersionInfoResponse(
        serverVersionInfo: json["server_version_info"] != null
            ? List<int>.from(
                json["server_version_info"].map(
                  (x) => x is int ? x : int.tryParse(x.toString()) ?? 0,
                ),
              )
            : null,
        serverVersion: json["server_version"],
        serverSerie: json["server_serie"],
        protocolVersion: json["protocol_version"],
      );

  Map<String, dynamic> toJson() => {
    "server_version_info": serverVersionInfo != null
        ? List<dynamic>.from(serverVersionInfo!.map((x) => x))
        : null,
    "server_version": serverVersion,
    "server_serie": serverSerie,
    "protocol_version": protocolVersion,
  };
}
