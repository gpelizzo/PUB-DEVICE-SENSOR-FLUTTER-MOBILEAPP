enum ENM_ERROR_CODE {
  ERROR_API_RESPONSE_STATUS_CODE,
  ERROR_API_QUERY,
  ERROR_NO_FAVORITE_CLIENT,
}

class GlobalException implements Exception {
  ENM_ERROR_CODE _errorCode;
  dynamic _statusCode;

  GlobalException(this._errorCode, this._statusCode);

  String buildMessage() {
    switch (_errorCode) {
      case ENM_ERROR_CODE.ERROR_API_RESPONSE_STATUS_CODE:
        return '#001 - API Response Status Code Error';
        break;

      case ENM_ERROR_CODE.ERROR_API_QUERY:
        return '#002 - API Query Error';
        break;

      case ENM_ERROR_CODE.ERROR_NO_FAVORITE_CLIENT:
        return '#003 - no favorite client';
        break;

      default:
        return '';
        break;
    }
  }
}
