class Response {
  bool isException;
  dynamic responseBody;

  Response.error({this.isException = true});

  Response.success({this.responseBody, this.isException = false});

  @override
  String toString() {
    // TODO: implement toString
    return """{
      isException: $isException,
      response: $responseBody
    }""";
  }
}
